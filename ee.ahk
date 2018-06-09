/*
  EE Explorer Extension
  @RAWSEQ
  
  Push / Key on explorer.
  [Ctrl + h] Key to Help

*/

#IfWinActive ahk_class CabinetWClass

  ActivateMode()
  {
    Global pb1
    Global pb2
    Global pb3
    Global pb4
    Global pb5
    Global rlist
    Global pprev
    Global fpath

    IniRead, fpath, ee.ini, General, FirstPath, C:
    IniRead, rlist, ee.ini, General, ReplaceList, 

    ControlFocus, Edit1

    Send, ^l

    Sleep, 150

    GetPath(file)
    if(!RegExMatch(file, "^([A-Za-z]:|\\\\)")){
      SetPath(fpath)
    }else{
      SetPath(RegExReplace(file, "\\$", ""))
    }

    Sleep, 50
    SendKey("{End}")
    Sleep, 50

    SendKey("\")
  }

  InActiveMode()
  {
    ControlGetFocus, test, ahk_class CabinetWClass
    if(test=="Edit1"){
      return False
    }else{
      return True
    }
  }

  SetPath(file)
  {
    ControlSetText, Edit1, %file%
  }

  GetPath(ByRef file)
  {
    ControlGetText, file, Edit1
  }

  GetComboPos(ByRef x, ByRef y, ByRef w, ByRef h)
  {
    ControlGetPos, x, y, w, h, Edit1
  }

  SendKey(key)
  {
    ControlSend, Edit1, %key%
  }

  UpperPath(file)
  {
    ret := RegExReplace(file, "\\?[^\\]+[\\]?$", "")
    return ret
  }

  /::
    
    if(InActiveMode())
    {
      ActivateMode()
    }
    else
    {
      GetPath(file)
      FileGetShortcut, %file%, OutTarget, OutDir, OutArgs, OutDesc, OutIcon, OutIconNum, OutRunState
      if OutTarget =
      {
        GetPath(file)
        if RegExMatch(file, "\\$") > 0
        {
          SendKey("{End}")
          SendKey("{Backspace}")
        }
        SendKey("\")
        GetPath(file)
        if file = \
        {
          ActivateMode()
        }
      }
      else
      {
        GetPath(pprev)
        SetPath(OutTarget)
        SendKey("{End}")
        text = Shortcutted from %pprev%
        ShowTip(text)
      }
    }
  return

  Tab::
    if(InActiveMode())
    {
      Send, {Tab}
      return
    }
    SendKey("{Down}")
  return

  +Tab::
    if(InActiveMode())
    {
      Send, +{Tab}
      return
    }
    SendKey("{Up}")
  return

  ^Backspace::
    if(InActiveMode())
    {
      Send, ^{Backspace}
      return
    }
    GetPath(file)
    filerep := UpperPath(file)
    SetPath(RegExReplace(filerep, "\\+$", ""))
    if filerep =
      return
    Send, {End}
    Send, \
  return

  ^Enter::
    if(InActiveMode())
      return
    GetPath(pprev)
    rpath = %pb1% %pb2% %pb3% %pb4% %pb5%
    SetPath(rpath)
    SendKey("{Home}")
    Send, +{End}
  return

  ^q::
    if(InActiveMode())
      return
    if rlist =
      return
    GetPath(pprev)
    GetPath(file)
    cnt = 0
    Loop
    {
      cnt += 1
      FileReadLine, line, %rlist%, %cnt%
      if ErrorLevel <> 0
        break
      p1 := RegExReplace(line, "^([^\=]*)\=(.*)$", "$1")
      p2 := RegExReplace(line, "^([^\=]*)\=(.*)$", "$2")
      if p1 =
        continue
      StringReplace, file, file, %p1%, %p2%, All
      if ErrorLevel = 0
      {
        text = Converted From %pprev%
        ShowTip(text)
        break
      }
    }
    SetPath(file)
    SendKey("{End}")
  return

  ^b::
    if pprev = 
      return
    sprev = %pprev%
    GetPath(pprev)
    SetPath(sprev)
    SendKey("{End}")
    text = Undo ..
    ShowTip(text)
  return

  ^1::
    SavePath(1, pb1)
  return
  ^+1::
    LoadPath(1, pb1)
  return
  
  ^2::
    SavePath(2, pb2)
  return
  ^+2::
    LoadPath(2, pb2)
  return

  ^3::
    SavePath(3, pb3)
  return
  ^+3::
    LoadPath(3, pb3)
  return

  ^4::
    SavePath(4, pb4)
  return
  ^+4::
    LoadPath(4, pb4)
  return

  ^5::
    SavePath(5, pb5)
  return
  ^+5::
    LoadPath(5, pb5)
  return

  ^d::
    GetPath(dir)
    FileCreateDir %dir%
    if ErrorLevel = 0
    {
      text = CreatedDir %dir%
      ShowTip(text)
    }
    else
    {
      ShowTip("Error...")
    }
  return

  ^s::
    dt:=A_Now
    Send, %dt%
  return

  ^h::
    if(InActiveMode())
    {
      Send, ^h
      return
    }
    ShowTip("EE Explorer Extension`n [/]=Next directory [Ctrl+Backspace]=Prev directory [Tab]=Next suggestion [Shift + Tab]=Prev suggestion `n [Ctrl + s]=Set date [Ctrl + d]=Create directory")

  return

  SavePath(num, ByRef ppath)
  {
    if(InActiveMode())
      return
    GetPath(ppath)
    text = Saved to [%num%] %ppath%
    ShowTip(text)
  }

  LoadPath(num, ByRef ppath)
  {
    if(InActiveMode())
      return
    GetPath(pprev)
    SetPath(ppath)
    SendKey("{End}")
    text = Loaded from [%num%] %ppath%
    ShowTip(text)
  }

  ShowTip(text)
  {
    GetComboPos(x, y, w, h)
    yh := y + h
    ToolTip , %text%, %x%, %yh%
    SetTimer, RemoveToolTip, 3000
  }

  RemoveToolTip:
    SetTimer, RemoveToolTip, Off
    ToolTip
  return
return
