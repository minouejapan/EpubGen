(*
  表紙画像用のコンテナ:OEBPS\Text\titlepage.xhtmlとして保存されます
*)

const
  TITLEPAGE = '<?xml version=''1.0'' encoding=''UTF-8''?>'#13#10
            + '<html xmlns="http://www.w3.org/1999/xhtml" xmlns:epub="http://www.idpf.org/2007/ops" xml:lang="ja">'#13#10
            + '  <head>'#13#10
            + '    <meta name="cover" content="true"/>'#13#10
            + '      <title>Cover</title>'#13#10
            + '        <style type="text/css" title="override_css">'#13#10
            + '            @page {padding: 0pt; margin:0pt}'#13#10
            + '            body { text-align: center; padding:0pt; margin: 0pt; }'#13#10
            + '        </style>'#13#10
            + '    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>'#13#10
            + '  </head>'#13#10
            + '  <body>'#13#10
            + '    <div>'#13#10
            + '      <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" width="100%" height="100%" viewBox="0 0 1200 1600" preserveAspectRatio="none">'#13#10
            + '        <image width="1200" height="1600" xlink:href="../Images/cover.jpg"/>'#13#10
            + '      </svg>'#13#10
            + '    </div>'#13#10
            + '  </body>'#13#10
            + '</html>'#13#10;

