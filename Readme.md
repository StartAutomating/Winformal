

[Official Website](http://winformal.start-automating.com)


    
    
### Winformal is a small PowerShell module that allows you to write Winforms UI in script.  This is a very simple UI written in Winformal:

    New-Form -controls {    
        New-Button -Text "Click Me" -On_Click {
            $this.Parent.Close()
        } -Left 50 -Top 50 -Width 200 -Height 200 
    } -Show


#### Winformal works off of the same engine as WPK, the predecessor to ShowUI.  These are both vastly superior ways to script a UI, because they are built using WPF instead of WinForms.   


#### WinFormal was built after a small challenge, and is a proof of concept of using the WPK engine to process different types of data.  Because WinForms can do a lot less than WPF, Winformal is a lot simpler and smaller than it's cousin.  Hence the name.  

#### If you find yourself writing Winforms in PowerShell, the least you can do is use Winformal to make life less painful.


