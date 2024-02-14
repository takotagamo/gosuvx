# gosuvx

subset of Gosu on RPG Maker XP/VX

## usage of sample scene

append Gosu.rb as section "Gosu".  
and append Scene_GosuMain.rb as section "Scene_GosuMain".

### launch from default Scene_Title

append menu entry in "Scene_Title.main" (XP) or "Scene_Title.create_command_window" (VX).

``` ruby
    ...
    s4 = "gosuvx sample"
    @command_window = Window_Command.new(192, [s1, s2, s3, s4])
```

append branch in "Scene_Title.update".

``` ruby
      case @command_window.index
      ...
      when 3  # gosuvx
        $scene = Scene_GosuMain.new(MyWin.new)
```
