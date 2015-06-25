function Out-PasteBin {
	<#
	.SYNOPSIS
	A PowerShell function to output to a Stikked PasteBin. 
		It fully supports being used in the current pipeline or simply cat'ing a text file. 
		The URL for the Paste is copied to the Clipboard for ease of access.
	Its recommended that this function be added to your PowerShell Profile to guarantee availability
	PowerShell Profiles - http://technet.microsoft.com/en-us/library/bb613488(v=VS.85).aspx 
	.PARAMETER <inputPipeline>
	Inbound object that will be converted to String for uploading to Stikked PasteBin
	.PARAMETER <Language>
	Code Language. Default = "text"
	.PARAMETER <username>
	Username. Default = current Windows logged in Username.
	.PARAMETER <Private>
	None private Pastes will be publicly listed and will appear on recent lists etc. Default = True (Private)
	.PARAMETER <expireMinutes>
	Paste liftime in Minutes. Default = 30.
	.EXAMPLE
	Get-VM | Out-PasteBin
	.EXAMPLE
	Get-ChildItem | Out-PasteBin -expireMinutes 120
	.EXAMPLE
	cat Out-PasteBin.ps1 | Out-PasteBin -language PowerShell
	.NOTES
		Author: jfrmilner/John Milner
		Blog  : http://jfrmilner.wordpress.com 
		File Name: Out-PostBin.ps1
		Requires: Powershell V2
		Legal: This script is provided "AS IS" with no warranties or guarantees, and confers no rights. You may use, modify, reproduce, and distribute this script file in any way provided that you agree to give the original author credit.
		Version: v1.0 - 2015/06/18
	#>
    param(
	   	[parameter(ValueFromPipeline=$true, ValueFromRemainingArguments=$true)]
	    $inputPipeline
		,
		[ValidateSet("html5", "css", "javascript", "php", "python", "ruby", "lua", "bash", "erlang", `
		"go", "c", "cpp", "diff", "latex", "sql", "xml", "text", "0", "4cs", "6502acme", "6502kickass",`
		"6502tasm", "68000devpac", "abap", "actionscript", "actionscript3", "ada", "algol68", "apache",` 
		"applescript", "apt_sources", "asm", "asp", "autoconf", "autohotkey", "autoit", "avisynth", "awk",` 
		"bascomavr", "basic4gl", "bf", "bibtex", "blitzbasic", "bnf", "boo", "c_loadrunner", "c_mac", `
		"caddcl", "cadlisp", "cfdg", "cfm", "chaiscript", "cil", "clojure", "cmake", "cobol", "coffeescript",`
		"csharp", "cuesheet", "d", "dcs", "delphi", "div", "dos", "dot", "e", "ecmascript", "eiffel", "email", `
		"epc", "euphoria", "f1", "falcon", "fo", "fortran", "freebasic", "fsharp", "gambas", "gdb", "genero", `
		"genie", "gettext", "glsl", "gml", "gnuplot", "groovy", "gwbasic", "haskell", "hicest", "hq9plus", `
		"html4strict", "icon", "idl", "ini", "inno", "intercal", "io", "j", "java", "java5", "jquery", "klonec", `
		"klonecpp", "lb", "lisp", "llvm", "locobasic", "logtalk", "lolcode", "lotusformulas", "lotusscript", `
		"lscript", "lsl2", "m68k", "magiksf", "make", "mapbasic", "matlab", "mirc", "mmix", "modula2", "modula3",`
		"mpasm", "mxml", "mysql", "newlisp", "nsis", "oberon2", "objc", "objeck", "ocaml", "oobas", "oracle11", `
		"oracle8", "oxygene", "oz", "pascal", "pcre", "per", "perl", "perl6", "pf", "pic16", "pike", "pixelbender", `
		"pli", "plsql", "postgresql", "povray", "powerbuilder", "powershell", "proftpd", "progress", "prolog", `
		"properties", "providex", "purebasic", "q", "qbasic", "rails", "rebol", "reg", "robots", "rpmspec", `
		"rsplus", "sas", "scala", "scheme", "scilab", "sdlbasic", "smalltalk", "smarty", "systemverilog", "tcl",`
		"teraterm", "thinbasic", "tsql", "typoscript", "unicon", "uscript", "vala", "vb", "vbnet", "verilog", "vhdl",`
		"vim", "visualfoxpro", "visualprolog", "whitespace", "whois", "winbatch", "xbasic", "xorg_conf", "xpp", `
		"yaml", "z80", "zxbasic")]
		[string]$language = "text"
		,
		[string]$username = [Environment]::UserName
		,
		[bool]$private = $true
		,
		[int]$expireMinutes = 30
	    )
	begin {
		Add-Type -AssemblyName System.Web
		Add-Type -AssemblyName System.Windows.Forms
		[array]$text=@()
	}
    process {
		$text += $inputPipeline
	}
	end {
		#Create Paste string from input
		$string = [System.Web.HttpUtility]::UrlEncode($($text | Format-Table -AutoSize | Out-String))
		$Global:PSContent = @() 
		$Global:PSContent += "private=$([int]$private)&"
		$Global:PSContent += "lang=$($language)&"
		$Global:PSContent += "name=$($username)&"
		$Global:PSContent += "expire=$($expireMinutes)&"
		$Global:PSContent += "title=pipeline&"
		$Global:PSContent += "text=$($string)"
		try
		 {
			#Upload to Stikked PasteBin. Change the Uri to your hosted Stikked PasteBin.
			Invoke-WebRequest -Uri 'http://paste.scratchbook.ch/api/create' -Method Post -Body $PSContent -OutVariable response | Out-Null
			
			#Copy Stikked URL response to Clipboard
			Write-Host $('[copied to clipboard] Postbin URL: {0}' -f $response.Content) -ForegroundColor Green -BackgroundColor Blue
			[System.Windows.Forms.Clipboard]::SetText( $response.Content, 'UnicodeText' )
		 }
		catch [system.exception]
		 {
		  	"caught a system exception"
		 }
	}
}
