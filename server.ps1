$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:8080/")
$listener.Start()
Write-Host "CHRGD dev server running at http://localhost:8080/"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path

while ($listener.IsListening) {
    try {
        $ctx = $listener.GetContext()
        $req = $ctx.Request
        $res = $ctx.Response
        $path = $req.Url.LocalPath
        if ($path -eq "/") { $path = "/index.html" }
        $file = Join-Path $root $path.TrimStart('/')
        if (Test-Path $file -PathType Leaf) {
            $bytes = [System.IO.File]::ReadAllBytes($file)
            switch ([System.IO.Path]::GetExtension($file)) {
                ".html" { $res.ContentType = "text/html; charset=utf-8" }
                ".css"  { $res.ContentType = "text/css; charset=utf-8" }
                ".js"   { $res.ContentType = "text/javascript; charset=utf-8" }
                default { $res.ContentType = "application/octet-stream" }
            }
            $res.ContentLength64 = $bytes.Length
            $res.OutputStream.Write($bytes, 0, $bytes.Length)
        } else {
            $res.StatusCode = 404
        }
        $res.Close()
    } catch {}
}
