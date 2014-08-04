#requires -version 2.0
 
[CmdletBinding()]
param
(
)
 
$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
function PSScriptRoot { $MyInvocation.ScriptName | Split-Path }
Trap { throw $_ }
 
function Register-ClipboardWatcher
{
    if (-not (Test-Path Variable:Global:ClipboardWatcher))
    {
        Register-ClipboardWatcherType
        $Global:ClipboardWatcher = New-Object ClipboardWatcher
 
        Register-EngineEvent -SourceIdentifier PowerShell.Exiting -SupportEvent -Action `
        {
            Unregister-ClipboardWatcher
        }
    }
 
    return $Global:ClipboardWatcher
}
 
function Unregister-ClipboardWatcher
{
    if (Test-Path Variable:Global:ClipboardWatcher)
    {
        $Global:ClipboardWatcher.Dispose();
        Remove-Variable ClipboardWatcher -Scope Global
        Unregister-Event -SourceIdentifier ClipboardWatcher
    }
}
 
function Register-ClipboardWatcherType
{
    Add-Type -ReferencedAssemblies System.Windows.Forms, System.Drawing -Language CSharpVersion3 -TypeDefinition `
@"
using System;
using System.Drawing;
using System.Runtime.InteropServices;
using System.Threading;
using System.Windows.Forms;
 
public class ClipboardWatcher : IDisposable
{
    readonly Thread _formThread;
    bool _disposed;
 
    public ClipboardWatcher()
    {
        _formThread = new Thread(() => { new ClipboardWatcherForm(this); })
                      {
                          IsBackground = true
                      };
 
        _formThread.SetApartmentState(ApartmentState.STA);
        _formThread.Start();
    }
 
    public void Dispose()
    {
        if (_disposed)
            return;
        Disposed();
        if (_formThread != null && _formThread.IsAlive)
            _formThread.Abort();
        _disposed = true;
        GC.SuppressFinalize(this);
    }
 
    ~ClipboardWatcher()
    {
        Dispose();
    }
 
    public event Action<string> ClipboardTextChanged = delegate { };
    public event Action Disposed = delegate { };
 
    public void OnClipboardTextChanged(string text)
    {
        ClipboardTextChanged(text);
    }
}
 
public class ClipboardWatcherForm : Form
{
    public ClipboardWatcherForm(ClipboardWatcher clipboardWatcher)
    {
        HideForm();
        RegisterWin32();
        ClipboardTextChanged += clipboardWatcher.OnClipboardTextChanged;
        clipboardWatcher.Disposed += () => InvokeIfRequired(Dispose);
        Disposed += (sender, args) => UnregisterWin32();
        Application.Run(this);
    }
 
    void InvokeIfRequired(Action action)
    {
        if (InvokeRequired)
            Invoke(action);
        else
            action();
    }
 
    public event Action<string> ClipboardTextChanged = delegate { };
 
    void HideForm()
    {
        FormBorderStyle = FormBorderStyle.None;
        ShowInTaskbar = false;
        Load += (sender, args) => { Size = new Size(0, 0); };
    }
 
    void RegisterWin32()
    {
        User32.AddClipboardFormatListener(Handle);
    }
 
    void UnregisterWin32()
    {
        if (IsHandleCreated)
            User32.RemoveClipboardFormatListener(Handle);
    }
 
    protected override void WndProc(ref Message m)
    {
        switch ((WM) m.Msg)
        {
            case WM.WM_CLIPBOARDUPDATE:
                ClipboardChanged();
                break;
 
            default:
                base.WndProc(ref m);
                break;
        }
    }
 
    void ClipboardChanged()
    {
        if (Clipboard.ContainsText())
            ClipboardTextChanged(Clipboard.GetText());
    }
}
 
public enum WM
{
    WM_CLIPBOARDUPDATE = 0x031D
}
 
public class User32
{
    const string User32Dll = "User32.dll";
 
    [DllImport(User32Dll, CharSet = CharSet.Auto)]
    public static extern bool AddClipboardFormatListener(IntPtr hWndObserver);
 
    [DllImport(User32Dll, CharSet = CharSet.Auto)]
    public static extern bool RemoveClipboardFormatListener(IntPtr hWndObserver);
}
"@
 
}
 
function Register-ClipboardTextChangedEvent
{
    param
    (
        [ScriptBlock] $Action
    )
 
    $watcher = Register-ClipboardWatcher
    Register-ObjectEvent $watcher -EventName ClipboardTextChanged -Action $Action -SourceIdentifier ClipboardWatcher
}
 
Register-ClipboardTextChangedEvent -Action `
    {
        param
        (
            [string] $text
        )
 
		$res = "{{"+$text
		$res = $res -ireplace "scored[.]" ,"}}"
		$res = $res -ireplace "{{[^}]+}}" ,""
		
		$res = $res -ireplace "Bookmark this question" ,"|"
		
		$res = $res -ireplace "Submit Back" ,""
		$res = $res -ireplace "Submit Forward " ,""
		$res = $res -ireplace "Open Bookmarks " ,""
		$res = $res -ireplace "Open Bookmarks " ,""
		
		$question = $res.split("|")[0]
		$question = $question -replace "\n" ,""
		$question = $question -replace "\r" ,""
		$answers = $res.split("|")[1] 
		$answers = $answers.trim()
		$answers = $answers -replace "\n","|"
		$answers = $answers -replace "\r",""
		$answers = $answers.split("|")
		
		$question = 'question = new Question { Name = "' + $question.substring(0,4) + '",Description ="'+$question+'",Type = QuestionType.MultipleOption,Test = test};'
		
		"" | Add-Content -Path D:\test.txt		
		$question | Add-Content -Path D:\test.txt
		'context.Questions.AddOrUpdate(q => q.Name, question);' | Add-Content -Path D:\test.txt
		
		for ($i=0; $i -lt $answers.length; $i++) {
			$answer = $answers[$i]
			$answer = 'context.Answers.AddOrUpdate(q => q.Name, new Answer { Name = "'+$answer+'", IsCorrect = false, Value = false,Question = question});'
			$answer| Add-Content -Path D:\test.txt
		}
		
		Add-Type -AssemblyName System.Windows.Forms
		[System.Windows.Forms.Clipboard]::Clear()
		
    }