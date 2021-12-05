(*
  EPUB用スタイルシート：OEBPS\Styles\style.cssとして保存されます
*)
STYLECSS = '@charset "utf-8";'#13#10
  + 'html {'#13#10'    -epub-writing-mode: vertical-rl;'#13#10'    writing-mode: vertical-rl;'#13#10'}'#13#10 // 縦書き
  + 'body{'#13#10'    writing-mode: vertical-rl;'#13#10'    -webkit-writing-mode: vertical-rl;'#13#10
  + '    -epub-writing-mode: vertical-rl;'#13#10'    line-height: 1.75;'#13#10'    text-align: justify;'#13#10
  + '    font-family:serif;'#13#10'    margin:0;'#13#10'    padding:0;'#13#10'    font-size:100%;'#13#10'}'#13#10
  + '.title-text{'#13#10'    margin:0; padding:0;'#13#10'    -epub-writing-mode:horizontal-tb;'#13#10
  + '    writing-mode:horizontal-tb;'#13#10'}'#13#10
  + '.vertical {'#13#10'    writing-mode: vertical-rl;'#13#10'    -webkit-writing-mode: vertical-rl;'#13#10
  + '    -epub-writing-mode: vertical-rl;'#13#10'}'#13#10
  + '.horizontal{'#13#10'    writing-mode:horizontal-tb;'#13#10'    -epub-writing-mode:horizontal-tb;'#13#10
  + '    -webkit-writing-mode:horizontal-tb;'#13#10'}'#13#10
  + '.tcy{'#13#10'    -webkit-text-combine: horizontal;'#13#10'}'#13#10
  + '.table-cell {'#13#10'    display: table-cell;'#13#10'    vertical-align: middle;'#13#10'}'#13#10
  + 'h1{'#13#10'    text-indent:0em;'#13#10'    font-family:sans-serif;'#13#10'    font-size:1.5em;'#13#10'    font-weight:bold;'#13#10'}'#13#10
  + 'h2{'#13#10'    text-indent:1em;'#13#10'    font-family:sans-serif;'#13#10'    font-size:1.3em;'#13#10'    font-weight:bold;'#13#10'}'#13#10
  + 'h3{'#13#10'    text-indent:2em;'#13#10'    font-family:sans-serif;'#13#10'    font-size:1.2em;'#13#10'    font-weight:bold;'#13#10'}'#13#10
  + 'h4{'#13#10'    text-indent:3em;'#13#10'    font-family:sans-serif;'#13#10'    font-size:1.0em;'#13#10'    font-weight:bold;'#13#10'}'#13#10
  + 'b{'#13#10'    font-weight:bold;'#13#10'}'#13#10
  + 'i{'#13#10'    font-style:italic;'#13#10'}'#13#10
  + 'p{'#13#10'    text-indent:0;'#13#10'    margin:0;'#13#10'}'#13#10
  + 'p.pagebreak{'#13#10'    page-break-after: always;'#13#10'}'#13#10
  + 'p.indent1{'#13#10'    margin-top: 1em;'#13#10'}'#13#10
  + 'p.indent2{'#13#10'    margin-top: 2em;'#13#10'}'#13#10
  + 'p.indent3{'#13#10'    margin-top: 3em;'#13#10'}'#13#10
  + 'p.indent4{'#13#10'    margin-top: 4em;'#13#10'}'#13#10
  + 'p.indent5{'#13#10'    margin-top: 5em;'#13#10'}'#13#10
  + 'p.left{'#13#10'    text-align: left;'#13#10'}'#13#10
  + 'p.center{'#13#10'    text-align: center;'#13#10'}'#13#10
  + 'p.right{'#13#10'    text-align: right;'#13#10'}'#13#10
  + 'em.dots{'#13#10'    font-style: normal;'#13#10'    -webkit-text-emphasis: filled circle;'#13#10'    text-emphasis: filled circle;'#13#10'}'#13#10
  + 'em.ten{'#13#10'    font-style: normal;'#13#10'    -webkit-text-emphasis: dot;'#13#10'    text-emphasis: dot;'#13#10'}'#13#10
  + 'em.sesame{'#13#10'    font-style: normal;'#13#10'    -webkit-text-emphasis: sesame;'#13#10'    text-emphasis: filled sesame;'#13#10'}'#13#10;
