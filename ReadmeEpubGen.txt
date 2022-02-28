Delphi用EPUB作成ユニットEpubGen

  このユニットは電子書籍用フォーマットであるEPUB3.2仕様に準拠した日本語縦書き用
  のEPUBファイルを作成するためのものです
  尚、Delphi XE2で作成していますので、XE2以前のバージョンでは動作するかどうか
  不明です

    InitializeEpub      新しいEpubファイルの作成を準備します
      引数   TEpubInfo  Epubファイルを作成するための基本情報

    EPubAddPage         １話分の情報を追加します
      引数   TEpisInfo  追加する１話の情報

    FinalizeEpub        追加した全ての情報を元に目次ファイルを構成しEPUBファイル
                        を作成する

    ZipPath             ZIP.EXEのフルパス名を指定する（初期値は'zip.exe'）
                        zip.exeにパスが通っている場合は省略可

配布ファイルの構成

  EpubGen.pas           EPUB作成ユニット本体
  stype.inc             style.css生成用定義ファイル
  titlepage.inc         titlepage.xhtml生成用定義ファイル
  
  Text2Epub.dpr         EpuGenテスト用サンプルプロジェクト
  Text2EpubUnit.pas
  Text2EpubUnit.dfm
  
  Text2Epub.exe

使い方
  配布アーカイブに同梱されているサンプルプロジェクトText2EPubを参照してください
  尚、EPUBファイル作成のためにはzip.exeが必要となりますので、下のIRLから入手して
  インストールして下さい


  作成したEpubの確からしさについては以下の方法で確認しました。
  ・EPUB-Checker(https://www.pagina.gmbh/produkte/epub-checker/)にて作成された
    EPUBファイルにエラーがないことを確認しています（表紙画像や挿絵がひとつもない
    場合のみ「EPUBが空のディレクトリOEBPS/Images/を含んでいます.」と警告が出ます）

  ・calibre(https://calibre-ebook.com/)にて正常に表示できることを確認しています

  ・超縦書ビュワー(https://www.bpsinc.jp/epub.html#chotategaki)で正常に表示できる
    ことを確認しています
    Windows上のビュワーとしてはこのビュワーがおすすめです

  ・Reasily-EPUB Reader(https://play.google.com/store/apps/details?id=com.gmail.jxlab.app.reasily&hl=ja&gl=US)
    にてAndroidタブレット上で正常に表示できることを確認しています

  ・Kinoppy for Windows(https://k-kinoppy.jp/for-windowsdt.html)ではアプリの本棚
    に書籍として登録する際に、表紙画像がないものは正常に登録出来ますが表紙画像が
    あるものは「内部エラーが発生しました」となり登録出来ません
    しかしながら、エクスプローラ上でEPUBファイルをKinnopy fo Windowsで直接開いた
    場合には、表紙画像があってもなくても正常に表示されます
    なぜそうなるのか原因は不明ですが、出力されたEPUBフォルダ・ファイルをWSL2上の
    Ubuntuターミナル上でzip ver3.0を用いてEPUBファイル化したものは正常に書籍登録
    が出来ます
    Linux用とWindows用のzip出力サイズが違うことはわかっていますが、なぜ違うのかと
    なぜWindows上で作成したEPUBを書籍登録出来ないのかはわかりません

  ライセンス
    Appach2.0


  zip.exeは以下から入手して下さい
  https://sourceforge.net/projects/gnuwin32/files/zip/3.0/


  更新の履歴
   Ver1.1  2022/02/28  章・話に階層化した目次の生成が不完全だった不具合を修正
   Ver1.0  2021/10/30  最初のバージョン
 
 
