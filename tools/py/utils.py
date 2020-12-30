def clear_screen():
    print('\033c');

def clear_scrollback():
    print(chr(27) + '[3J');

def clear():
    clear_screen();
    clear_scrollback();
