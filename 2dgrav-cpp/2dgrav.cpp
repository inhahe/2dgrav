//todo: bounce off eachother mode
//      clump by clinging onto eachother
//      don't attract if ix/iy near d 
//      meld colors on clump


/*         ______   ___    ___ 
 *        /\  _  \ /\_ \  /\_ \ 
 *        \ \ \L\ \\//\ \ \//\ \      __     __   _ __   ___ 
 *         \ \  __ \ \ \ \  \ \ \   /'__`\ /'_ `\/\`'__\/ __`\
 *          \ \ \/\ \ \_\ \_ \_\ \_/\  __//\ \L\ \ \ \//\ \L\ \
 *           \ \_\ \_\/\____\/\____\ \____\ \____ \ \_\\ \____/
 *            \/_/\/_/\/____/\/____/\/____/\/___L\ \/_/ \/___/
 *                                           /\____/
 *                                           \_/__/
 *
 *      Example program showing how to write a Windows screensaver. This
 *      uses a fullscreen DirectX mode when activated normally, or the
 *      GDI interface functions when it is running in preview mode from
 *      inside the Windows screensaver selection dialog. When in
 *      configuration mode, it just uses a standard Windows API dialog.
 *      This also demonstrates how to load, save, and modify the
 *      configuration options.
 *
 *      Compile this like a normal executable, but rename the output
 *      program to have a .scr extension, and then copy it into your
 *      'windows/system' directory (or 'winnt/system32' directory under
 *      Windows NT/2000/XP).
 *
 *      By Shawn Hargreaves.
 *
 *      Modified by Andrei Ellman to demonstrate loading, saving and
 *      modifying of configuration settings.
 *
 *      See readme.txt for copyright information.
 */


#include <time.h>
#include "allegro.h"
#include "winalleg.h"
#include "2dgrav.rh"
#include <math.h>



#define INISETTINGNAME_SHOWBLUECROSS   "showbluecross"
#define INISETTINGDEFAULT_SHOWBLUECROSS   1

#define INISETTINGNAME_SHOWEXTRATEXT   "showextratext"
#define INISETTINGDEFAULT_SHOWEXTRATEXT   1

#define INISETTINGNAME_MESSAGE   "message"
#define INISETTINGDEFAULT_MESSAGE   "This message may be changed"

#define MAX_MESSAGE_LENGTH 40

int setting_show_blue_cross, setting_show_extra_text;
char saver_message[MAX_MESSAGE_LENGTH+1];

int ox, oy;


int screen_width = 1024;
int screen_height = 768;

int objectsnum = 10;
double G = 2;
struct object {
  double x, y, ix, iy, mass, lx, ly;
  int size, color; };
object *objects;

bool circles=true, dots=false, lines=false, web=false, erase=true, 
 negatives=false, linear=false, bounce=false, randomsizes=false,
 clump=true;
int following=-1, controlling=-1;

BITMAP *buf;

void set_saver_config(void)
{
   /* Because of the different ways screensavers are invoked from the shell,
    * we must make absolutely sure we set the INI file to be in the same
    * directory as the SCR file. set_config_file() is not sufficient in these
    * circumstances, so we have to set the ABSOLUTE path of the INI file.
    */

   char szPath[512], szINIFile[512];

   /* As we are using SYSTEM_NONE as the system driver, we cannot use Allegro's
    * get_executable_name(). Thankfully, this is a Windows specific program, so
    * we can get away with the equivalent Windows code below.
    */
   if(GetModuleFileName(NULL, szPath, sizeof(szPath))==0)
      szPath[0]=0;

   replace_filename(szINIFile, szPath, "scrsave.ini", 512);

   set_config_file(szINIFile);
}



void load_config(void)
{
   set_saver_config();

   setting_show_blue_cross = get_config_int(NULL, INISETTINGNAME_SHOWBLUECROSS, INISETTINGDEFAULT_SHOWBLUECROSS);
   setting_show_extra_text = get_config_int(NULL, INISETTINGNAME_SHOWEXTRATEXT, INISETTINGDEFAULT_SHOWEXTRATEXT);
   ustrzcpy(saver_message, MAX_MESSAGE_LENGTH+1, get_config_string(NULL, INISETTINGNAME_MESSAGE, INISETTINGDEFAULT_MESSAGE));


}



void save_config(void)
{

   set_saver_config();

   set_config_int(NULL, INISETTINGNAME_SHOWBLUECROSS, setting_show_blue_cross);
   set_config_int(NULL, INISETTINGNAME_SHOWEXTRATEXT, setting_show_extra_text);
   set_config_string(NULL, INISETTINGNAME_MESSAGE, saver_message);


}



/* initialises our graphical effect */
void ss_init(void)
  {

  ox=oy=0;

  show_mouse(screen);
  clear_bitmap(buf);
  load_config();
  srand(time(NULL));

  objects = new object[objectsnum];

  for(int i=0; i<objectsnum; i++) {
    objects[i].x = rand()%screen_width;
    objects[i].y = rand()%screen_height;
    objects[i].lx = objects[i].x;
    objects[i].ly = objects[i].y;
    objects[i].ix = rand()%1000/1000.0;
    objects[i].iy = rand()%1000/1000.0;
    objects[i].mass = rand()%10/10.0;
    if(randomsizes) {
      if(linear) {
        objects[i].size=sqrt(rand()%400); }
      else {
        objects[i].size=pow(rand()%8000, 1/3.0); } }
    else {
      if(linear) {
        objects[i].size = sqrt(objects[i].mass*40*3.14159); }
      else {
        objects[i].size=pow(objects[i].mass*1066*3.14159, 1/3.0); } }
    objects[i].color = rand()%144+32; }


}


/* animates the graphical effect */
void ss_update(void)  {
  double dx, dy, dx2dy2, d;
  for(int i=0; i<objectsnum; i++) {
    objects[i].lx=objects[i].x;
    objects[i].ly=objects[i].y;
    if(controlling==i) {
      objects[i].x = mouse_x;
      objects[i].y = mouse_y;}
    else {
      for(int ii=0; ii<objectsnum; ii++) {
        if(i!=ii) {
          dx = objects[ii].x-objects[i].x;
          dy = objects[ii].y-objects[i].y;
          dx2dy2=dx*dx+dy*dy;
          d = sqrt(dx2dy2);
          if(clump && d<objects[i].size+objects[ii].size) {
            objects[i].x+=dx*objects[ii].mass/float(objects[i].mass+objects[ii].mass);
            objects[i].y+=dy*objects[ii].mass/float(objects[i].mass+objects[ii].mass);
            objects[i].ix+=(objects[ii].ix-objects[i].ix)*objects[ii].mass/float(objects[i].mass+objects[ii].mass);
            objects[i].iy+=(objects[ii].iy-objects[i].iy)*objects[ii].mass/float(objects[i].mass+objects[ii].mass);
            objects[i].mass+=objects[ii].mass;
            if(objects[ii].size>objects[i].size) {
              objects[i].color=objects[ii].color; }
            if(linear) {
              objects[i].size = sqrt((objects[i].size*objects[i].size
               *3.14159+objects[ii].size*objects[ii].size*3.14159)
               /3.14159); }
            else {
              objects[i].size = pow((pow(objects[i].size, 3)*4.0/3.0
               *3.14159+pow(objects[ii].size, 3)*4.0/3.0*3.14159)
               *3.0/4.0/3.14159, 1.0/3.0); } 
            objects[ii]=objects[objectsnum-1];
            objectsnum--; }
          if(linear) {
            objects[i].ix+=dx/d*objects[ii].mass*G;
            objects[i].iy+=dy/d*objects[ii].mass*G; }
          else {
            objects[i].ix+=dx/dx2dy2*objects[ii].mass*G;
            objects[i].iy+=dy/dx2dy2*objects[ii].mass*G; } } 
}
            
      objects[i].x+= objects[i].ix;
      objects[i].y+= objects[i].iy;
      if(bounce) {
        if(circles) {
          if(objects[i].x-objects[i].size<=0||objects[i].x+objects[i].size>=screen_width-1) {
            objects[i].ix*=-1;
            objects[i].x+=objects[i].ix; }
          if(objects[i].y-objects[i].size<=0||objects[i].y+objects[i].size>=screen_height-1) {
            objects[i].iy*=-1;
            objects[i].y+=objects[i].iy; } }
        else {
          if(objects[i].x<0||objects[i].x>=screen_width) {
            objects[i].ix*=-1;
            objects[i].x+=objects[i].ix; }
          if(objects[i].y<0||objects[i].y>=screen_height) {
            objects[i].iy*=-1;
            objects[i].y+=objects[i].iy; } } }
            
} 
}

}


/* draws the graphical effect */
void ss_draw(void)  {

      if(following!=-1) {
        ox=objects[following].x;
        oy=objects[following].y; }
      if(erase) {
        clear_bitmap(buf);}
      if(bounce) {
        rect(buf, -ox, -oy, screen_width-1-ox, screen_height-1-oy, 15);}
      for(int i=0; i<objectsnum; i++) {                   
        if(circles) {
          circlefill(buf, objects[i].x-ox, objects[i].y-oy, 
           objects[i].size, objects[i].color); }
        if(dots) {
          putpixel(buf, objects[i].x-ox, objects[i].y-oy, objects[i].color); }
        if(lines) {
          line(buf, objects[i].x-ox, objects[i].y-oy, objects[i].lx-ox, 
           objects[i].ly-oy, objects[i].color); }
        if(web) {
          for(int i=0; i<objectsnum-1; i++) {
            for(int ii=i+1; ii<objectsnum; ii++) {
              line(buf, objects[i].x-ox, objects[i].y-oy, objects[ii].x-ox,
               objects[ii].y-oy, objects[i].color); } } } }
        

 }





/* shuts down the graphical effect */
void ss_exit(void)
{
delete(objects);
}



/* dialog procedure for the settings dialog */
BOOL CALLBACK settings_dlg_proc(HWND hwndDlg, UINT uMsg, WPARAM wParam, LPARAM lParam)
{
   switch (uMsg) {

      case WM_INITDIALOG:
	 /* Set up the values for the controls, and grey them out if appropriate. */
	 SendMessage(GetDlgItem(hwndDlg, IDC_CHECK_BLUECROSS), BM_SETCHECK, (setting_show_blue_cross?BST_CHECKED:BST_UNCHECKED), 0);
	 SendMessage(GetDlgItem(hwndDlg, IDC_CHECK_SHOWMESSAGE), BM_SETCHECK, (setting_show_extra_text?BST_CHECKED:BST_UNCHECKED), 0);
	 SendMessage(GetDlgItem(hwndDlg, IDC_EDIT_MESSAGE), WM_SETTEXT, 0, (LPARAM) ((LPCTSTR) saver_message));
	 SendMessage(GetDlgItem(hwndDlg, IDC_EDIT_MESSAGE), EM_LIMITTEXT, MAX_MESSAGE_LENGTH, 0);
	 EnableWindow(GetDlgItem(hwndDlg, IDC_EDIT_MESSAGE), setting_show_extra_text);
	 break;


      case WM_COMMAND:
	 switch (LOWORD(wParam)) {

	    case IDC_CHECK_SHOWMESSAGE:
	       /* If this checkbox is changed, then we will grey-out the edit-box accordingly. */
	       EnableWindow(GetDlgItem(hwndDlg, IDC_EDIT_MESSAGE), (SendMessage(GetDlgItem(hwndDlg, IDC_CHECK_SHOWMESSAGE), BM_GETCHECK, 0, 0)==BST_CHECKED));
	       return 1;

	    case IDOK:
	       /* Read in the settings from the dialog. */
	       setting_show_blue_cross = (SendMessage(GetDlgItem(hwndDlg, IDC_CHECK_BLUECROSS), BM_GETCHECK, 0, 0)==BST_CHECKED?1:0);
	       setting_show_extra_text = (SendMessage(GetDlgItem(hwndDlg, IDC_CHECK_SHOWMESSAGE), BM_GETCHECK, 0, 0)==BST_CHECKED?1:0);
	       SendMessage(GetDlgItem(hwndDlg, IDC_EDIT_MESSAGE), WM_GETTEXT, (WPARAM)(MAX_MESSAGE_LENGTH+1), (LPARAM) ((LPCTSTR) saver_message));

	       /* And now save these settings to the INI file. */
	       save_config();
	       EndDialog(hwndDlg, 1);
	       return 1;

	    case IDCANCEL:
	       EndDialog(hwndDlg, 0);
	       return 1;
	 }
	 break;
   }

   return 0;
}



/* the settings dialog function */
int do_settings(HANDLE hInstance, HANDLE hPrevInstance, HWND hParentWnd)
{
   if (install_allegro(SYSTEM_NONE, &errno, atexit) != 0)
      exit(0);

   load_config();

   DialogBox(hInstance, "ID_CONFIG_DLG", hParentWnd, settings_dlg_proc);

   return 0;
}



/* the password dialog function */
int do_password(HANDLE hInstance, HANDLE hPrevInstance, HWND hParentWnd)
{
    /* Load the password change DLL */
    HINSTANCE mpr = LoadLibrary(TEXT("MPR.DLL"));
    if (mpr)
    {
        /* Grab the password change function from it */
        typedef DWORD (PASCAL *PWCHGPROC)(LPCSTR, HWND, DWORD, LPVOID);
        PWCHGPROC pwd = (PWCHGPROC)GetProcAddress(mpr, "PwdChangePasswordA");

        /* Do the password change */
        if ( pwd != NULL )
            pwd("SCRSAVE", hParentWnd, 0, NULL);

        /* Free the library */
        FreeLibrary(mpr);
        mpr=NULL;
    }   

   return 0;
}



/* window procedure for the screensaver preview */
LRESULT CALLBACK preview_wnd_proc(HWND hwnd, UINT message, UINT wParam, LONG lParam)
{
   PAINTSTRUCT ps;
   HDC hdc;

   switch (message) {

      case WM_CREATE:
	 SetTimer(hwnd, 1, 15, NULL);
	 return 0;

      case WM_TIMER:
	 ss_update();
	 InvalidateRect(hwnd, NULL, FALSE);
	 return 0;

      case WM_PAINT:
	 hdc = BeginPaint(hwnd, &ps);
	 ss_draw();
	 set_palette_to_hdc(hdc, _current_palette);
	 draw_to_hdc(hdc, buf, 0, 0);
	 EndPaint(hwnd, &ps);
	 return 0;

      case WM_DESTROY:
	 KillTimer(hwnd, 1);
	 PostQuitMessage(0);
	 return 0;
   }

   return DefWindowProc(hwnd, message, wParam, lParam);
}



/* the screensaver preview function */
int do_preview(HANDLE hInstance, HANDLE hPrevInstance, HWND hParentWnd)
{
   WNDCLASS wndclass;
   HWND hwnd;
   MSG msg;
   RECT rc;

   if (!hPrevInstance) {
      wndclass.style = CS_HREDRAW | CS_VREDRAW;
      wndclass.lpfnWndProc = preview_wnd_proc;
      wndclass.cbClsExtra = 0;
      wndclass.cbWndExtra = 0;
      wndclass.hInstance = hInstance;
      wndclass.hIcon = LoadIcon(NULL, IDI_APPLICATION);
      wndclass.hCursor = LoadCursor(NULL, IDC_ARROW);
      wndclass.hbrBackground = NULL;
      wndclass.lpszMenuName = NULL;
      wndclass.lpszClassName = "sspreview";

      RegisterClass(&wndclass);
   }

   if (hParentWnd)
      GetClientRect(hParentWnd, &rc);
   else
      rc.right = rc.bottom = 256;

   if (install_allegro(SYSTEM_NONE, &errno, atexit) != 0)
      exit(0);
   set_palette(default_palette);
   set_gdi_color_format();

   buf = create_bitmap(rc.right, rc.bottom);

   ss_init();
   ss_update();

   hwnd = CreateWindow("sspreview", NULL, WS_CHILD, 
		       0, 0, rc.right, rc.bottom, 
		       hParentWnd, NULL, hInstance, NULL);

   ShowWindow(hwnd, SW_SHOW);
   UpdateWindow(hwnd);

   while (GetMessage(&msg, NULL, 0, 0)) {
      TranslateMessage(&msg);
      DispatchMessage(&msg);
   }

   ss_exit();
   destroy_bitmap(buf);

   return msg.wParam;
}



/* display switch callback */
static int foreground = TRUE;

static void dispsw_callback(void)
{
   foreground = FALSE;
}


/* run the saver normally, in fullscreen mode */
int do_saver(HANDLE hInstance, HANDLE hPrevInstance, HWND hParentWnd)
{
   HANDLE scrsaver_mutex;
   int mx, my, t;

   /* prevent multiple instances from running */
   scrsaver_mutex = CreateMutex(NULL, TRUE, "Allegro screensaver");

   if (!scrsaver_mutex || (GetLastError() == ERROR_ALREADY_EXISTS))
      return -1;

   if (allegro_init() != 0)
      return -1;
   install_keyboard();
   install_mouse();
   install_timer();
   
   set_color_depth(8);
     
   if (set_gfx_mode(GFX_DIRECTX_ACCEL, screen_width, screen_height, 0, 0) != 0)
      if (set_gfx_mode(GFX_DIRECTX_SOFT, screen_width, screen_height, 0, 0) != 0)
         if (set_gfx_mode(GFX_DIRECTX_SAFE, screen_width, screen_height, 0, 0) != 0) {
            ReleaseMutex(scrsaver_mutex);
            return -1;
         }

   set_display_switch_mode(SWITCH_BACKAMNESIA);  /* not SWITCH_AMNESIA */
   set_display_switch_callback(SWITCH_OUT, dispsw_callback);

   buf = create_bitmap(screen_width, screen_height);
       
   ss_init();
   ss_update();

   mx = mouse_x;
   my = mouse_y;

   t = retrace_count;
   bool escape=false;
   while (escape==false) {
     
     if(keypressed()) {
       int c;         
       c = readkey();
       switch(c&0xff) {
         case 27:
         escape=true; 
         break;
         case 'c':
         case 'C':
         circles=!circles;
         break;
         case 'd':
         case 'D':
         dots=!dots;
         break;
         case 'l':
         case 'L':
         lines=!lines;
         break;
         case 'w':
         case 'W':
         web=!web;
         break;
         case 'e':
         case 'E':
         erase=!erase;
         break;
         case 'n':
         case 'N':
         clear_bitmap(buf);
         break;
         case 'b':
         case 'B':
         bounce=!bounce;
         case '0':
         for(int i=0; i<objectsnum; i++) {
           objects[i].ix=0;
           objects[i].iy=0; }
         break;
         case 0:
         switch(c>>8) {
           case KEY_RIGHT:
           ox+=screen_width/5; 
           clear_bitmap(buf);
           break;
           case KEY_LEFT:
           ox-=screen_width/5; 
           clear_bitmap(buf);
           break;
           case KEY_UP:
           oy-=screen_width/5; 
           clear_bitmap(buf);
           break;
           case KEY_DOWN:
           oy+=screen_width/5; 
           clear_bitmap(buf);
           break; } }
         
/*       else if((c>>8)==KEY_LEFT) {
         ox-=screen_width/5; }    
       else if((c>>8)==KEY_UP) {
         oy-=screen_width/5; }    
       else if((c>>8)==KEY_DOWN) {
         oy+=screen_width/5; }    
*/


}
/*
       if(key[KEY_RIGHT]) {
         ox+=5; }
       if(key[KEY_LEFT]) {
         ox-=5; }
       if(key[KEY_UP]) {
         oy-=5; }
       if(key[KEY_DOWN]) {
         oy+=5; }
*/


      while (t < retrace_count) {
	 ss_update();
	 t++;
      }

      ss_draw();
      show_mouse(buf);      
      blit(buf, screen, 0, 0, 0, 0, screen_width, screen_height);
      show_mouse(screen);

      poll_mouse();
   }

   ss_exit();
   destroy_bitmap(buf);

   ReleaseMutex(scrsaver_mutex);
   return 0;
}



/* the main program body */
int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpszCmdParam, int nCmdShow)
{
   HWND hwnd;
   char *args;

   args = lpszCmdParam;

   if ((args[0] == '-') || (args[0] == '/'))
      args++;

   if ((args[0]) && ((args[1] == ' ') || (args[1] == ':')))
      hwnd = (HWND)atoi(args+2);
   else
      hwnd = GetActiveWindow();

   switch (utolower(args[0])) {

      case 'c':
	 return do_settings(hInstance, hPrevInstance, hwnd);

      case 'a':
	 return do_password(hInstance, hPrevInstance, hwnd);

      case 'p':
	 return do_preview(hInstance, hPrevInstance, hwnd);

      case 's':
	 return do_saver(hInstance, hPrevInstance, hwnd);
   }
  return do_saver(hInstance, hPrevInstance, hwnd);

}
