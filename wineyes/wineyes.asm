bits 32

extern RegisterClassExA
extern GetStockObject, LoadIconA, LoadCursorA
extern CreateWindowExA, AdjustWindowRectEx
extern ShowWindow, UpdateWindow
extern GetMessageA, TranslateMessage, DispatchMessageA
extern DefWindowProcA, PostQuitMessage
extern ExitProcess, GetModuleHandleA
extern MessageBoxA
extern SetLayeredWindowAttributes

extern SetWindowPos, GetWindowRect
extern SetFocus, SetCapture
extern SetTimer, KillTimer

extern InvalidateRect
extern ClientToScreen, GetSystemMetrics
extern BeginPaint, EndPaint
extern Ellipse, CreateSolidBrush, CreatePen, FillRect
extern DeleteObject, SelectObject

WM_DESTROY equ 0x0002
WM_PAINT equ 0x000f
WM_CREATE equ 0x0001
WM_MOVE equ 0x0003
WM_MOUSEMOVE equ 0x0200
WM_ERASEBKGND equ 0x0014
WM_TIMER equ 0x0113

MK_LBUTTON equ 0x0001

CS_VREDRAW equ 0x01
CS_HREDRAW equ 0x02
CS_OWNDC equ 0x0020
CS_CLASSDC equ 0x0040
CS_PARENTDC equ 0x0080

WS_OVERLAPPED equ 0x00
WS_CAPTION equ 0x00C00000
WS_SYSMENU equ 0x00080000
WS_CHILD equ 0x40000000
WS_POPUP equ 0x80000000

WS_EX_LAYERED equ 0x00080000
WS_EX_APPWINDOW equ 0x00040000
WS_EX_TOPMOST equ 0x00000008

CW_USEDEFAULT equ 0x80000000

SW_SHOW equ 0x5

SWP_NOSIZE equ 0x0001
SWP_NOZORDER equ 0004

SM_CXFULLSCREEN equ 0x10
SM_CYFULLSCREEN equ 0x11

COLOR_WINDOW equ 0x5
NULL_BRUSH equ 0x0
GRAY_BRUSH equ 0x2

PS_SOLID equ 0x00

IDI_APPLICATION equ 32512
IDC_ARROW equ 32512
IDC_HAND equ 32649

struc RECT
	left: resd 1
	top: resd 1
	right: resd 1
	bottom: resd 1
endstruc

struc POINT
	x: resd 1
	y: resd 1
endstruc

struc PAINTSTRUCT
	hdc: resd 1
	fErase: resd 1
	rcPaint: resb RECT_size
	fRestore: resd 1
	fIncUpdate: resd 1
	rbgReserved: resb 32
endstruc

struc MSG
	hwnd: resd 1
	message: resd 1
	wParam: resd 1
	lParam: resd 1
	time: resd 1
	pt: resb POINT_size
	lPrivate: resd 1
endstruc

struc WNDCLASSEXA
	cbSize: resd 1
	style: resd 1
	lpfnWndProc: resd 1
	cbClsExtra: resd 1
	cbWndExtra: resd 1
	hInstance: resd 1
	hIcon: resd 1
	hCursor: resd 1
	hbrBackground: resd 1
	lpszMenuName: resd 1
	lpszClassName: resd 1
	hIconSm: resd 1
endstruc

section .data

szClassName:
szWndCaption: db "WinEyes",0x00

szErrorCaption: db "Error!",0x00
szErrorMsg: db "Some strange error occured!",0x0a,0x00

section .bss

hMyWindow: resd 1
hCurInst: resd 1
WndClass: resb WNDCLASSEXA_size
msg: resb MSG_size
rcWindow: resb RECT_size

ps: resb PAINTSTRUCT_size
hdcMyWindow: resd 1
hbrWhite: resd 1
hbrBlack: resd 1
hPen: resd 1

ptMouseScr: resb POINT_size
ptMouseScrOld: resb POINT_size

ptLeftEyeScr: resb POINT_size
ptRightEyeScr: resb POINT_size
ptLeftEyeCur: resb POINT_size
ptRightEyeCur: resb POINT_size

ptScrSize: resb POINT_size

section .text

Error:
	push dword 0x01
	call ExitProcess
	ret

Start:
	push dword 0x00
	call GetModuleHandleA
	mov [hCurInst], eax

	mov [WndClass+cbSize], dword WNDCLASSEXA_size
	mov [WndClass+style], dword 0
	mov [WndClass+lpfnWndProc], dword WndProc
	mov [WndClass+cbClsExtra], dword 0x4
	mov [WndClass+cbWndExtra], dword 0x4
	mov [WndClass+hInstance], eax
	push dword 100
	push dword [hCurInst]
	call LoadIconA
	mov [WndClass+hIcon], eax
	mov [WndClass+hIconSm], eax
	push dword IDC_HAND
	push dword 0x00
	call LoadCursorA
	mov [WndClass+hCursor], eax
	push dword 0x000000ff
	call CreateSolidBrush
	mov [WndClass+hbrBackground], eax
	mov [WndClass+lpszMenuName], dword 0x00
	mov [WndClass+lpszClassName], dword szClassName

	push dword WndClass
	call RegisterClassExA

	xor eax, eax
	mov [rcWindow + top], eax
	mov [rcWindow + left], eax
	mov ebx, 200
	mov [rcWindow + bottom], ebx
	mov ebx, 300
	mov [rcWindow + right], ebx
	push dword 0x00
	push dword 0x00
	push dword WS_POPUP
	push dword rcWindow
	call AdjustWindowRectEx

	push dword 0x00
	push dword [hCurInst]
	push dword 0x00
	push dword 0x00
	mov eax, [rcWindow + bottom]
	mov ebx, [rcWindow + top]
	sub eax, ebx
	push eax
	mov eax, [rcWindow + right]
	mov ebx, [rcWindow + left]
	sub eax, ebx
	push eax
	push dword CW_USEDEFAULT
	push dword CW_USEDEFAULT
	push dword WS_POPUP
	push dword szWndCaption
	push dword szClassName
	push dword WS_EX_LAYERED | WS_EX_TOPMOST
	call CreateWindowExA
	mov [hMyWindow], eax

	push dword 0x1
	push byte 0x00
	push dword 0x000000ff
	push eax
	call SetLayeredWindowAttributes

	push dword 0x00
	push dword 0x32
	push dword 0xff
	push dword [hMyWindow]
	call SetTimer

	push dword SW_SHOW
	push dword [hMyWindow]
	call ShowWindow
	push dword [hMyWindow]
	call UpdateWindow

	.loop_begin:
	push dword 0x00
	push dword 0x00
	push dword 0x00
	push dword msg
	call GetMessageA
	cmp eax, 0x00
	je .loop_end
	
	push dword msg
	call TranslateMessage
	push dword msg
	call DispatchMessageA

	mov eax, [msg+pt+x]
	mov [ptMouseScr+x], eax
	mov eax, [msg+pt+y]
	mov [ptMouseScr+y], eax

	jmp .loop_begin
	.loop_end:

	push dword [msg+wParam]
	call ExitProcess

WndProc:
	push ebp
	mov ebp, esp

	mov ebx, [ebp+12]
	cmp ebx, WM_CREATE
	je .case_create
	cmp ebx, WM_TIMER
	je .case_timer
	cmp ebx, WM_MOVE
	je .case_move
	cmp ebx, WM_MOUSEMOVE
	je .case_mousemove
	cmp ebx, WM_DESTROY
	je .case_destroy
	cmp ebx, WM_PAINT
	je .case_paint
	jmp .case_def

	.case_create:
	push dword 0x00ffffff
	call CreateSolidBrush
	mov [hbrWhite], eax

	push dword 0x00000000
	call CreateSolidBrush
	mov [hbrBlack], eax
	
	push dword 0x00000000
	push dword 8 ;grubosc linii
	push dword PS_SOLID
	call CreatePen
	mov [hPen], eax

	xor eax, eax
	jmp .fn_end

	.case_timer:
	push dword 0x00
	push dword 0x00
	push dword [hMyWindow]
	call InvalidateRect

	xor eax, eax
	jmp .fn_end

	.case_move:
	mov [ptLeftEyeScr+x], dword 75
	mov [ptLeftEyeScr+y], dword 100
	mov [ptRightEyeScr+x], dword 225
	mov [ptRightEyeScr+y], dword 100
	
	push dword ptLeftEyeScr
	push dword [hMyWindow]
	call ClientToScreen

	push dword ptRightEyeScr
	push dword [hMyWindow]
	call ClientToScreen

	xor eax, eax
	jmp .fn_end

	.case_mousemove:
	mov edx, [ptMouseScr+y]
	mov eax, [ptMouseScr+x]
	mov [ptMouseScrOld+y], edx
	mov [ptMouseScrOld+x], eax
	
	mov ebx, [ebp+20]
	mov eax, ebx
	shl eax, 16
	shr eax, 16
	mov [ptMouseScr+x], eax
	mov eax, ebx
	shr eax, 16
	mov [ptMouseScr+y], eax

	push dword ptMouseScr
	push dword [hMyWindow]
	call ClientToScreen

	mov eax, [ebp+16]
	and eax, MK_LBUTTON
	cmp eax, 0x00
	je .cont_mm

	push rcWindow
	push dword [hMyWindow]
	call GetWindowRect

	mov eax, [ptMouseScr+x]
	mov ebx, [ptMouseScrOld+x]
	sub eax, ebx
	mov ecx, [rcWindow+left]
	add ecx, eax
	mov [rcWindow+left], ecx
	mov eax, [ptMouseScr+y]
	mov ebx, [ptMouseScrOld+y]
	sub eax, ebx
	mov ecx, [rcWindow+top]
	add ecx, eax
	mov [rcWindow+top], ecx

	push dword SWP_NOSIZE | SWP_NOZORDER
	push dword 0x00
	push dword 0x00
	push dword [rcWindow+top]
	push dword [rcWindow+left]
	push dword 0x00
	push dword [hMyWindow]
	call SetWindowPos

	.cont_mm:

	xor eax, eax
	jmp .fn_end

	.case_paint:
	push dword ps
	push dword [hMyWindow]
	call BeginPaint
	mov [hdcMyWindow], eax

	push dword [hbrWhite]
	push dword [hdcMyWindow]
	call SelectObject
	push dword [hPen]
	push dword [hdcMyWindow]
	call SelectObject

	push dword 200-5
	push dword 150-5
	push dword 5
	push dword 5
	push dword [hdcMyWindow]
	call Ellipse
	push dword 200-5
	push dword 300-5
	push dword 5
	push dword 150+5
	push dword [hdcMyWindow]
	call Ellipse

	push dword [hbrBlack]
	push dword [hdcMyWindow]
	call SelectObject

	;Rysowanie zrenic
	mov [ptLeftEyeCur+x], dword 75
	mov [ptLeftEyeCur+y], dword 100
	mov [ptRightEyeCur+x], dword 225
	mov [ptRightEyeCur+y], dword 100
	
	push dword SM_CXFULLSCREEN
	call GetSystemMetrics
	mov [ptScrSize+x], eax
	push dword SM_CYFULLSCREEN
	call GetSystemMetrics
	mov [ptScrSize+y], eax
    
	;lewa zrenica
	mov eax, [ptMouseScr+x]
	mov edx, [ptLeftEyeScr+x]
	sub eax, edx
	push eax ;ebp-4
	fild dword [ebp-4] ;ptMouseScr.x-ptLeftEyeScr.x ;-800
	mov eax, [ptScrSize+x]
	mov edx, [ptLeftEyeScr+x]
	sub eax, edx
	push eax ;ebp-8
	fild dword [ebp-8] ;ptScrSize.x-ptLeftEyeScr.x ;100
	fdivp ;(ptMouseScr.x-ptLeftEyeScr.x)/(ptScrSize.x-ptLeftEyeScr.x) ;-8
	mov [ebp-4], dword 45
	fimul dword [ebp-4] ;((ptMouseScr.x-ptLeftEyeScr.x)/(ptScrSize.x-ptLeftEyeScr.x))*45 ;360
	fistp dword [ebp-4]
	mov eax, [ptLeftEyeCur+x]
	mov edx, [ebp-4]
	;check <-45 >45
	cmp edx, -45
	jge .cont_paint1
	mov edx, -45
	.cont_paint1:
	cmp edx, 45
	jle .cont_paint2
	mov edx, 45
	.cont_paint2:
	add eax, edx
	mov [ptLeftEyeCur+x], eax
	add esp, 8
    
	mov eax, [ptMouseScr+y]
	mov edx, [ptLeftEyeScr+y]
	sub eax, edx
	push eax ;ebp-4
	fild dword [ebp-4]
	mov eax, [ptScrSize+y]
	mov edx, [ptLeftEyeScr+y]
	sub eax, edx
	push eax ;ebp-8
	fild dword [ebp-8]
	fdivp
	mov [ebp-4], dword 45
	fimul dword [ebp-4]
	fistp dword [ebp-4]
	mov eax, [ptLeftEyeCur+y]
	mov edx, [ebp-4]
	;check <-45 >45
	cmp edx, -45
	jge .cont_paint3
	mov edx, -45
	.cont_paint3:
	cmp edx, 45
	jle .cont_paint4
	mov edx, 45
	.cont_paint4:
	add eax, edx
	mov [ptLeftEyeCur+y], eax
	add esp, 8
	
	mov edx, dword [ptLeftEyeCur+y]
	add edx, 8
	push edx
	mov eax, dword [ptLeftEyeCur+x]
	add eax, 8
	push eax
	sub edx, 16
	push edx
	sub eax, 16
	push eax
	push dword [hdcMyWindow]
	call Ellipse

	;prawa zrenica
	mov eax, [ptMouseScr+x]
	mov edx, [ptRightEyeScr+x]
	sub eax, edx
	push eax ;ebp-4
	fild dword [ebp-4] 
	mov eax, [ptScrSize+x]
	mov edx, [ptRightEyeScr+x]
	sub eax, edx
	push eax ;ebp-8
	fild dword [ebp-8] 
	fdivp 
	mov [ebp-4], dword 45
	fimul dword [ebp-4] 
	fistp dword [ebp-4]
	mov eax, [ptRightEyeCur+x]
	mov edx, [ebp-4]
	;check <-45 >45
	cmp edx, -45
	jge .cont_paint5
	mov edx, -45
	.cont_paint5:
	cmp edx, 45
	jle .cont_paint6
	mov edx, 45
	.cont_paint6:
	add eax, edx
	mov [ptRightEyeCur+x], eax
	add esp, 8
    
	mov eax, [ptMouseScr+y]
	mov edx, [ptRightEyeScr+y]
	sub eax, edx
	push eax ;ebp-4
	fild dword [ebp-4]
	mov eax, [ptScrSize+y]
	mov edx, [ptRightEyeScr+y]
	sub eax, edx
	push eax ;ebp-8
	fild dword [ebp-8]
	fdivp
	mov [ebp-4], dword 45
	fimul dword [ebp-4]
	fistp dword [ebp-4]
	mov eax, [ptRightEyeCur+y]
	mov edx, [ebp-4]
	;check <-45 >45
	cmp edx, -45
	jge .cont_paint7
	mov edx, -45
	.cont_paint7:
	cmp edx, 45
	jle .cont_paint8
	mov edx, 45
	.cont_paint8:
	add eax, edx
	mov [ptRightEyeCur+y], eax
	add esp, 8
	
	mov edx, dword [ptRightEyeCur+y]
	add edx, 8
	push edx
	mov eax, dword [ptRightEyeCur+x]
	add eax, 8
	push eax
	sub edx, 16
	push edx
	sub eax, 16
	push eax
	push dword [hdcMyWindow]
	call Ellipse

	push dword ps
	push dword [hMyWindow]
	call EndPaint

	xor eax, eax
	jmp .fn_end

	.case_destroy:
	push dword [hbrWhite]
	call DeleteObject

	push dword [hbrBlack]
	call DeleteObject

	push dword [hPen]
	call DeleteObject

	push dword 0xff
	push dword [hMyWindow]
	call KillTimer

	push dword 0x00
	call PostQuitMessage

	xor eax, eax
	jmp .fn_end

	.case_def:
	push dword [ebp+20]
	push dword [ebp+16]
	push dword [ebp+12]
	push dword [ebp+8]
	call DefWindowProcA

	.fn_end:
	mov esp, ebp
	pop ebp
	ret


