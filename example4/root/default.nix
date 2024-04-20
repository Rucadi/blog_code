{query}:
let
    randomNumber =  builtins.readFile (builtins.fetchurl http://www.randomnumberapi.com/api/v1.0/random);
    randomNumberList = builtins.fromJSON randomNumber;
    randomNumberStr = toString (builtins.elemAt randomNumberList 0);
in
{
    random.GET = randomNumberStr;

    GET = let 
        HTMX = "https://unpkg.com/htmx.org@1.9.11";
        content = ''
            int main()
            {
                __builtin_printf("Hello World\\n");
            }
        '';
        language = "cpp";
        theme = "vs-dark";
        
        monaco_style = ''
            .monaco {
            width: 100%;
            height: 50vh;
            border: 1px solid black;
            box-sizing: border-box;
            }
        '';

        button_style = ''
        .runcode {
            font-size: 20px; 
            padding: 10px 20px; 
            background-color: #4CAF50; 
            color: white; 
            border: none; 
            border-radius: 4px; 
            cursor: pointer;
            float: right;
        }
        '';
    
    in ''
        <!doctype html>
        <html lang="en">
        <head>
            <style>${button_style}</style>
            <style>${monaco_style}</style>
            <script src="${HTMX}"></script>
            <script type="module">
                import * as monaco from 'https://cdn.jsdelivr.net/npm/monaco-editor@0.39.0/+esm';
                window.editor = monaco.editor.create(
                    document.querySelector('.monaco'),{
                            value: `${content}`,
                            language: '${language}',
                            theme: '${theme}',
                            automaticLayout: true
                    }
                );
            </script>
            
            <link href="https://cdn.jsdelivr.net/npm/vscode-codicons@0.0.17/dist/codicon.min.css" rel="stylesheet">
        </head>

        <body> 
            <div class="monaco"></div>
            <button class="runcode" hx-vals='js:{code: editor.getValue()}' hx-get="/compile" hx-swap="innerHTML" hx-trigger="click" hx-target="#output">
            Run code!
            </button> 
            <div style="clear:both;"></div>
            <pre id="output"></pre>
        </body>
        </html>
    '';

    compile.GET = let 
            pkgs = import <nixpkgs> {};
            code = pkgs.writeText "main.cpp" query.code;
            compile_command = "${pkgs.gcc}/bin/g++ ${code}";
            run_command = "${pkgs.uutils-coreutils-noprefix}/bin/timeout 10 ./a.out";
        in
        builtins.readFile (
        pkgs.runCommand "gccCompile" {} 
        ''
            ${compile_command} &> tmp || true
            ${run_command} &>> tmp || echo "Timeout" >> tmp
            ${pkgs.uutils-coreutils-noprefix}/bin/tail -c 4096 tmp > $out
        '');
        
}