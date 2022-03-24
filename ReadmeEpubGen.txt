Delphi用EPUB作成ユニットEpubGen

  このユニットは電子書籍用フォーマットであるEPUB3.2仕様に準拠した日本語縦書き用
  のEPUBファイルを作成するためのものです
  尚、System.zipを使用しますのでコンパイルにはXE2以降のバージョンが必要です
  

    InitializeEpub      新しいEpubファイルの作成を準備します
      引数   TEpubInfo  Epubファイルを作成するための基本情報

    EPubAddPage         １話分の情報を追加します
      引数   TEpisInfo  追加する１話の情報

    FinalizeEpub        追加した全ての情報を元に目次ファイルを構成しEPUBファイル
                        を作成する

配布ファイルの構成

  EpubGen.pas           EPUB作成ユニット本体
  stype.inc             style.css生成用定義ファイル
  titlepage.inc         titlepage.xhtml生成用定義ファイル
  ReadmeEpubGen.txt     このファイル

  Text2Epub.dpr         EpuGenテスト用サンプルプロジェクト
  Text2EpubUnit.pas
  Text2EpubUnit.dfm
  Text2Epub.exe         サンプルプロジェクト実行ファイル


使い方
  配布アーカイブに同梱されているサンプルプロジェクトText2EPubを参照してください

  作成したEpubの確からしさについては以下の方法で確認しました。
  ・EPUB-Checker(https://www.pagina.gmbh/produkte/epub-checker/)にて作成された
    EPUBファイルにエラーがないことを確認しています（表紙画像や挿絵がひとつもない
    場合のみ「EPUBが空のディレクトリOEBPS/Images/を含んでいます.」と、外部リンク
    が含まれている場合に「参照されているリソース"～"がEPUB内に見つかりません」と
    警告が出ますが表示閲覧に支障はありません）

  ・calibre(https://calibre-ebook.com/)にて正常に表示できることを確認しています

  ・Kinoppy for Windows(https://k-kinoppy.jp/for-windowsdt.html)で正常に表示でき
    ることを確認しています
    Windows上のビュワーとしてはこのビュワーがおすすめです
    尚、アプリの本棚に書籍としてインポート登録する際に、表紙画像がある場合のみ
    「内部エラーが発生しました」となり登録出来ませんが原因は不明です

  ・Reasily-EPUB Reader(https://play.google.com/store/apps/details?id=com.gmail.jxlab.app.reasily&hl=ja&gl=US)
    にてAndroidタブレット上で正常に表示できることを確認しています


  ライセンス
    Apach2.0としています。
    Apach2.0はライセン的にはほぼなんでもありですので、そのまま流用、改変自由に
    お使いください


  ※最初のバージョンで必要だったzip.exeは不要となりました
  

  更新の履歴
    Ver1.2  2022/03/24  System.zipを使用することでzip.exeを不要とした
    Ver1.1  2022/02/28  章・話に階層化した目次の生成が不完全だった不具合を修正
    Ver1.0  2021/10/30  最初のバージョン
 
 