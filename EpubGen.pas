﻿(*
  EPUB作成用ユニットEpubGen

  このユニットは電子書籍用フォーマットであるEPUB3.2仕様に準拠した日本語縦書き用
  のEPUBファイルを作成するためのものです

    InitializeEpub      新しいEpubファイルの作成を準備します
      引数   TEpubInfo  Epubファイルを作成するための基本情報

    EPubAddPage         １話分の情報を追加します
      引数   TEpisInfo  追加する１話の情報

    FinalizeEpub        追加した全ての情報を元に目次ファイルを構成しEPUBファイルを
                        作成する


  使い方は配布アーカイブに同梱されているサンプルプロジェクトText2EPubを参照

  作成したEpubの確からしさについては以下の方法で確認しました。
  ・EPUB-Checker(https://www.pagina.gmbh/produkte/epub-checker/)にて作成されたEPUB
    ファイルにエラーがないことを確認しています（表紙画像や挿絵がひとつもない場合
    のみ、「EPUBが空のディレクトリOEBPS/Images/を含んでいます.」と警告が出ます）

  ・calibre(https://calibre-ebook.com/)にて正常に表示できることを確認しています


  ライセンス
    github上でApache2.0ライセンスで公開しています。
    A[ache2.0はほぼなんでもありのライセンスですので個人、業務に関わらず、どなたでも
    自由に使用することが出来ます。
    尚、使用に当たって発生したいかなる不具合に対してもいっさいの保証はしませんので、
    使用者個人の責任でご使用下さい。



  更新の履歴
    Ver1.9  2024/06/02  ベースディレクトリ名をトリムする際に内部の半角スペースも削除して
                        いた不具合を修正した
    Ver1.8  2024/01/04  作成するEPUBファイル名を外部から強制指定するためにグローバル変数
                        EpubFileを追加した
                        Epubフォルダを丸ごと削除するためグローバル変数EpubRootを追加した
    Ver1.7  2023/01/17  表紙画像cover.jpgがない場合はOPFにcover.jpg情報を書き込まないよう
                        にした
                        Sectionがない場合はnav.htmlにページリンクを書き込まないようにした
                        独自のcssファイルを指定できるようTEpubInfoにStyleSheetメンバーを
                        追加した
    Ver1.6  2022/12/23  BODYHEADテンプレートのDOCTYPE内容を変更した
    Ver1.6  2022/11/28  作品ファイル名の長さを指定するためのメンバーFNameLenをTEpubInfoに
                        追加した
    Ver1.5  2022/11/25  一部の変数をグローバル化した
                        EPUBフォルダ内の既存ファイル削除方法を変更した
    Ver1.4  2022/11/11  本文中に&nbsp;(半角スペース)があってもエラーとならないよう修正した
                        (ヘッダーを<!DOCTYPE html [ <!ENTITY nbsp "&#160;">]>に修正)
                        EpubAddImageで追加された画像ファイルをopfファイルのitemに追加する
                        ようにした
    Ver1.3  2022/11/09  表紙画像の処理が中途半端だったのを修正した
                        挿絵画像をbook.opfへのitemとして追加していなかった不具合を修正した
                        Epubを作成するフォルダ構成を変更した
    Ver1.2  2022/03/24  System.zipを使用することでzip.exeを不要とした
    Ver1.1  2022/02/28  章・話に階層化した目次の生成が不完全だった不具合を修正
    Ver1.0  2021/10/30  最初のバージョン
*)
unit EpubGen;

interface

uses
{$WARN UNIT_PLATFORM OFF}
	Vcl.FileCtrl,
{$WARN UNIT_PLATFORM ON}
  Winapi.Windows, System.SysUtils, System.Classes, Vcl.StdCtrls, System.DateUtils,
  System.IOUtils, System.Zip;

type
  // InitializeEpub用
  TEpubInfo = record
    BaseDir,            // Epubファイルを作成するための基準ディレクトリ
    Title,              // 作品のタイトル
    Auther,             // 作者名
    Publisher,          // 発行者名
    CoverImage,         // 表紙画像ファイル名
    StyleSheet: string; // cssファイル(指定しなければEPubGen規定のcssを使用する)
    FNameLen: integer;
  end;
  // EpubAddPage用
  TEpisInfo = record
    Chapter,            // 章タイトル
    Section,            // 話タイトル
    Episode: string;    // 本文
  end;

// 公開手続き
procedure InitializeEpub(EpubInfo: TEpubInfo);    // Epub作成の準備
procedure EPubAddPage(Episode: TEpisInfo);        // 一話分の情報を追加する
procedure EpubAddImage(ImageFile: string);        // 挿絵画像ファイルをEpubフォルダに追加する
procedure FinalizeEpub;                           // Epubを完成させる

// 公開変数（外部からアクセスする可能性があるものに限定）
var
  EpubRoot,           // Epubフォルダを保存するベースとなるフォルダ名
  EpubBase,           // Epubフォルダ名（ベースディレクトリ\EPUB）
  EpubName,           // Epubファイル名
  EpubFile: string;   // Epubユニット外からEPUBファイル名を設定する場合に使用する


implementation

const
  // mimetypeファイル用テンプレート
  MIMETYPE  = 'application/epub+zip';

  // cobtainer.xmlファイル用テンプレート
  CONTAINER = '<?xml version=''1.0'' encoding=''UTF-8''?>'#13#10
            + '<container version="1.0" xmlns="urn:oasis:names:tc:opendocument:xmlns:container">'#13#10
            + '  <rootfiles>'#13#10
            + '    <rootfile full-path="OEBPS/book.opf" media-type="application/oebps-package+xml" />'#13#10
            + '  </rootfiles>'#13#10
            + '</container>';

  // nav.xhtmlファイル用テンプレート
  NAVHEAD   = '<?xml version=''1.0'' encoding=''UTF-8''?>'#13#10
            + '<html xmlns="http://www.w3.org/1999/xhtml" xmlns:epub="http://www.idpf.org/2007/ops" lang="ja" xml:lang="ja">'#13#10
            + '  <head>'#13#10
            + '    <title>目次</title>'#13#10
            + '    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>'#13#10
            + '  </head>'#13#10
            + '  <body>'#13#10
            + '    <nav epub:type="toc">'#13#10
            + '      <ol>';

  NAVTITLE  = '        <li><a href="Text/chap1.xhtml">表紙</a></li>';
  NAVINTRO  = '        <li><a href="Text/chap2.xhtml">あらすじ</a></li>';

  NAVCHAP1  = '        <li><a href="Text/chap';
  NAVCHAP2  = '            <li><a href="Text/chap';
  NAVSECBG  = '          <ol>';
  NAVSECED  = '          </ol>'#13#10'        </li>';

  NAVCPMID  = '.xhtml">';
  NAVCPTL1  = '</a>';
  NAVCPTL2  = '</a></li>';
  NAVSEPL1  = '      </ol></li>';
  NAVSEPL2  = '      <ol>';

  NAVMID    = '      </ol>'#13#10
            + '    </nav>'#13#10;
  NAVCOVER  = '    <nav epub:type="landmarks" hidden="">'#13#10
            + '      <ol>'#13#10
            + '        <li><a href="Text/titlepage.xhtml" epub:type="titlepage">Title page</a></li>'#13#10
            + '      </ol>'#13#10
            + '   </nav>'#13#10;
  NAVTAIL   = '  </body>'#13#10
            + '</html>'#13#10;

  // opfファイル用テンプレート（このユニットではbook.opfというファイル名を使用する）
  OPFHEAD   = '<?xml version=''1.0'' encoding=''UTF-8''?>'#13#10
            + '<package unique-identifier="pub-id" version="3.0" xmlns="http://www.idpf.org/2007/opf">'#13#10
            + '    <metadata xmlns:dc="http://purl.org/dc/elements/1.1/">'#13#10
            + '        <dc:identifier id="pub-id">urn:uuid:'; // ここにUUIDを挿入
  OPFMID1   = '</dc:identifier>'#13#10
            + '        <dc:title>';       // ここにタイトルを挿入
  OPFMID2   = '</dc:title>'#13#10
            + '        <dc:creator>';     // ここに作者を挿入
  OPFMID3   = '</dc:creator>'#13#10;
  OPFMID4   = '        <dc:publisher>';
  OPFMID5   = '</dc:publisher>'#13#10;
  OPFMID6   = '        <dc:language>ja</dc:language>'#13#10
            + '        <meta name="cover" content="cover-image"/>'#13#10
            + '        <meta name="primary-writing-mode" content="vertical-rl"/>'#13#10 // 縦書き
            + '        <meta property="dcterms:modified">'; // ここにUTC日時を挿入
  OPFMID7   = '</meta>'#13#10
            + '    </metadata>'#13#10
            + '    <manifest>'#13#10;
  OPFCOVER  = '        <item id="titlepage" href="Text/titlepage.xhtml" media-type="application/xhtml+xml" properties="svg"/>'#13#10;

  OPFCHAPL  = '        <item id="chap';         // 1～Nの通し番号を追加する
  OPFCHAPM  = '" href="Text/chap';
  OPFCHAPR  = '.xhtml" media-type="application/xhtml+xml" />';

  OPFMID8   = '        <item id="nav" href="nav.xhtml" media-type="application/xhtml+xml" properties="nav" />'#13#10
            + '        <item id="css" href="/Styles/style.css" media-type="text/css" />'#13#10;
  OPFIMAGE  = '        <item id="cover-image" href="./Images/cover.jpg" properties="cover-image" media-type="image/jpeg" />'#13#10;
  OPFIMGLS  = '        <item id="img';
  OPFIMGLM  = '" href="Images/';
  OPFIMGLE  = '.jpg" media-type="image/jpeg" />'#13#10;
  OPFMID9   = '    </manifest>'#13#10
            + '    <spine page-progression-direction="rtl">'#13#10;
  OPFMID10  = '        <itemref idref="titlepage" />'#13#10;

  OPFITEML  = '        <itemref idref="chap';   // 1～Nの通し番号を追加する
  OPFITEMR  = '" />';

  OPFTAIL   = '    </spine>'#13#10
            + '</package>';

  // 小説各話本文xhtmlファイル用テンプレート
  BODYHEAD  = '<?xml version=''1.0'' encoding=''UTF-8''?>'#13#10
            //+ '<!DOCTYPE html [ <!ENTITY nbsp "&#160;">]>'#13#10
            // EPUB各話HTML内の&nbsp;を&#160;表記に変更する必要がある.
            + '<!DOCTYPE html>'#13#10
            + '<html xmlns="http://www.w3.org/1999/xhtml">'#13#10
            + '  <head>'#13#10
            + '    <meta charset="utf-8" />'#13#10
            + '    <link rel="stylesheet" href="../Styles/style.css" type="text/css" />'#13#10
            + '    <title>';
  BODYMID   = '</title>'#13#10
            + '  </head>'#13#10
            + '  <body>'#13#10;

  BODYTAIL  = '  </body>'#13#10
            + '</html>';

  // 表紙xhtmlファイル用テンプレート（表紙はタイトル名と作者名を表記する）
  COVERHEAD = '</title>'#13#10
            + '  </head>'#13#10
            + '  <body>'#13#10
            + '    <h1>';     // ここにタイトル名を挿入する

  COVERMID  = '</h1>'#13#10
            + '    <p class="right">';  // ここに作者名を挿入する

  COVERTAIL = '</p>'#13#10
            + '  </body>'#13#10
            + '</html>';

  // EPUBフォルダ
  OEBPS     = '\OEBPS';
  OEBPSTEXT = '\OEBPS\Text';
  OEBPSCSS  = '\OEBPS\Styles';
  OEBPSIMAGE= '\OEBPS\Images';
  METAINF   = '\META-INF';

{$I style.inc}          // style.cssの定義
{$I titlepage.inc}      // titlepage.xhtmlの定義

var
  BaseDir,              // Epubを作成するためのベースディレクトリ名
  EpubTitle,            // 作品のタイトル名
  EpubAuther,           // 作者名
  EpubPublisher,        // 発行者
  EpubEpub,             // OEBPSフォルダ
  EpubText,             // OEBPS\Textフォルダ
  EpubCss,              // OEBPS\Stylesフォルダ
  EpubImage,            // OEBPS\Imagesフォルダ
  EpubMetaInf,          // META-INFフォルダ
  Uuid,                 // UUID(GUID)
  CreateTime: string;   // 作成日時
  EpubFiles,            // Epubに保存するファイルリスト
  ChapLbl,              // チャプターラベル名
  Chapter: TStringList; // チャプタータイトル名
  ChapNo: integer;      // チャプター番号
  ChapNested,           // チャプターが章・話と階層化しているか
  IsCoverImg: Boolean;  // 表紙画像があるか
  ImageNum: integer;    // 挿絵画像数
  EpubNameLen: integer; // EPUBファイル名の長さ




// タイトル名をファイル名として使用出来るかどうかチェックし、使用不可文字が
// あれば修正する('-'に置き換える)
// フォルダ名の最後が'.'の場合、フォルダ作成時に"."が無視されてフォルダ名が
// 見つからないことになるため'.'も'-'で置き換える
function CreateEpubName(Title: string): string;
var
	i, l: integer;
  ttl, path: string;
  tmp: AnsiString;
  ch: char;
begin
  // タイトル名が長い場合は16文字まで詰める
  if Length(Title) > EPubNameLen then
    ttl := Copy(Title, 1, EpubNameLen)
  else
    ttl := Title;
  // ファイル名を一旦ShiftJISに変換して再度Unicode化することでShiftJISで使用
  // 出来ない文字を除去する
  tmp := AnsiString(ttl);
	path := string(tmp);
  l :=  Length(path);
  for i := 1 to l do
  begin
  	ch := Char(path[i]);
    if Pos(ch, '\/;:*?"<>|. '#$09) > 0 then
      path[i] := '-';
  end;
  Result := path;
end;

// 表紙画像を保存する
// 画像ファイルはcover.jpg決め打ちにしているので、元画像ファイルはjpgでなければならない
procedure CreateCoverImage(ImageFile: string);
begin
  if FileExists(ImageFile) then
  begin
    CopyFile(PWideChar(ImageFile), PWideChar(EpubImage + '\cover.jpg'), False);
    if FileExists(EpubImage + '\cover.jpg') then
    begin
      IsCoverImg := True;
    end;
  end;
end;

// 表紙を保存する
procedure CreateCover(Title, Auther: string);
var
  sl: TStringList;
begin
  if ChapNo = 0 then    // 初期化されていない
    Exit;
  sl := TStringList.Create;
  try
    sl.Text := BODYHEAD + '表紙' + COVERHEAD + Title + COVERMID + Auther + COVERTAIL;
    sl.WriteBOM := False;
    sl.SaveToFile(EpubText + '\chap1.xhtml', TEncoding.UTF8);
    // Epub(zip)に保存するファイルリストを準備する
    // zip書庫内に格納するフォルダデリミタはWindowsの\だとEpubリーダー側が読めないのでLinux形式の
    // /を使用する
    EpubFiles.Add('"' + EpubText + '\chap1.xhtml",OEBPS/Text/chap1.xhtml');
  finally
    sl.Free;
  end;
  Chapter.Add(',表紙');
  ChapLbl.Add('Chap1');
end;

// BaseDirフォルダにEPUB3を作成するための作業フォルダを作成して基本的なファイルを配置する
// BaseDir/タイトル名
//            └OEBPS
//                 └Styles
//                 └Images
//                 └Text
//            └META-INF
//        /タイトル名.epub  ←最終的にこのepubファイルが作成される
procedure InitializeEpub(EpubInfo: TEpubInfo);
var
  sl: TStringList;
  fs: TFileStream;
  d, t: string;
  dt: TDateTime;
  p: integer;
begin
  if EpubInfo.Title = '' then
    Exit;

  // 各リストと変数を初期化する
  Chapter.Clear;
  Chaplbl.Clear;
  EpubFiles.Clear;
  ChapNo        := 2;
  ChapNested    := False;
  IsCoverImg    := False;
  ImageNum      := 0;

  BaseDir       := EpubInfo.BaseDir;
  EpubRoot      := BaseDir;
  { ver1.9 2024/6/2
  p := Pos(' ', BaseDir);
  while p > 0 do
  begin
    Delete(BaseDir, p, 1);
    p := Pos(' ', BaseDir);
  end;
  }
  BaseDir := Trim(BaseDir); // ver1.9
  EpubTitle     := EpubInfo.Title;
  EpubAuther    := EpubInfo.Auther;
  EpubPublisher := EpubInfo.Publisher;
  EpubBase      := BaseDir + '\EPUB';// epubを構成するためのフォルダ名
  if (EpubInfo.FNameLen > 15) and (EpubInfo.FNameLen < 129) then
    EpubNameLen := EpubInfo.FNameLen
  else
    EpubNameLen := 64;

  // epub構成フォルダを作成する
  if not DirectoryExists(EpubBase) then
    ForceDirectories(EpubBase)
  // 既にフォルダが存在する場合はそのフォルダ内全てを削除する
  // （以前のファイルが残っているとEPUB作成時に悪影響があるため）
  else begin
    try
      if DirectoryExists(EpubBase) then
        TDirectory.Delete(EpubBase + '\*.*', True);
    except
      ;
    end;
  end;
  EpubEpub      := EpubBase + OEBPS;
  EpubText      := EpubBase + OEBPSTEXT;
  EpubCss       := EpubBase + OEBPSCSS;
  EpubImage     := EpubBase + OEBPSIMAGE;
  EpubMetaInf   := EpubBase + METAINF;
  if EpubFile <> '' then
    EpubName := EpubFile
  else
    EpubName      := BaseDir + '\' + CreateEpubName(EpubTitle) + '.epub'; // 最終的なepubファイル名
  // epub構成用のサブフォルダを作成する
  if not DirectoryExists(EpubEpub)    then ForceDirectories(EpubEpub);
  if not DirectoryExists(EpubText)    then ForceDirectories(EpubText);
  if not DirectoryExists(EpubCss)     then ForceDirectories(EpubCss);
  if not DirectoryExists(EpubImage)   then ForceDirectories(EpubImage);
  if not DirectoryExists(EpubMetaInf) then ForceDirectories(EpubMetaInf);

  // mimetypeファイルをASCII(1byte文字)で保存する
  // EPUB3.2の仕様上、文字列'application/epub+zip'の最後に改行コードがあっては
  // ならないようだ（改行コードがあるとエラーとなるビュワーが多い）
  fs := TFileStream.Create(EpubBase  + '\mimetype', fmCreate);
  try
    fs.Write(AnsiString(MIMETYPE), Length(AnsiString(MIMETYPE)));
  finally
    fs.Free;
  end;
  // 入力ファイルと同じフォルダにcover.jpgがあれば表紙画像を追加する
  if (EpubInfo.CoverImage <> '') and FileExists(EpubInfo.CoverImage) then
    CreateCoverImage(EpubInfo.CoverImage);
  // container.xmlとstyle.cssを保存する（UTF-8 BOMなしで書き込む）
  // Epub(zip)に保存するファイルリストを準備する
  EpubFiles.Add('"' + EpubBase + '\mimetype",mimetype');
  sl := TStringList.Create;
  try
    sl.Text := CONTAINER;
    sl.WriteBOM := False;
    sl.SaveToFile(EpubMetaInf + '\container.xml', TEncoding.UTF8);
    // StyleSheetに設定されたファイルがあればstyle.cssとして使用し、ファイルが存在しない
    // もしくは指定されていない場合はEpubGen規定のstyle.cssを使用する
    if (EpubInfo.StyleSheet <> '') and FileExists(EpubInfo.StyleSheet) then
      CopyFile(PWideChar(EpubInfo.StyleSheet), PWideChar(EpubCss + '\style.css'), False)
    else begin
      sl.Text := STYLECSS;
      sl.WriteBOM := False;
      sl.SaveToFile(EpubCss + '\style.css', TEncoding.UTF8);
    end;
    // Epub(zip)に保存するファイルリストを準備する
    EpubFiles.Add('"' + EpubMetaInf + '\container.xml",META-INF/container.xml');
    EpubFiles.Add('"' + EpubCss     + '\style.css",OEBPS/Styles/style.css');
    // 表紙画像があればtitlepage.xhtmlをコピーする
    if IsCoverImg then
    begin
      sl.Text := TITLEPAGE;
      sl.WriteBOM := False;
      sl.SaveToFile(EpubText + '\titlepage.xhtml', TEncoding.UTF8);
      // Epub(zip)に保存するファイルリストを準備する
      EpubFiles.Add('"' + EpubText    + '\titlepage.xhtml",OEBPS/Text/titlepage.xhtml');
    end;
    // 表紙を構築する
    CreateCover(EpubInfo.Title, EpubInfo.Auther);
  finally
    sl.Free;
  end;
  // uuidを準備する
  Uuid := LowerCase(TGUID.NewGuid.ToString());   // 文字列化したGUIDを取得
  Delete(Uuid, 1, 1);
  Delete(Uuid, Length(Uuid), 1);      // 最初と最後の{}を削除する
  // 作成時間をUTC時間で取得する
  dt := TTimeZone.Local.ToUniversalTime(Now);
  DateTimeToString(d, 'yyyy-mm-dd', dt);
  DateTimeToString(t, 'hh:nn:ss', dt);
  CreateTime := d + 'T' + t + 'Z';    // UTC時間の文字列を作成
end;

// 各話を保存する
procedure EPubAddPage(Episode: TEpisInfo);
var
  sl: TStringList;
  s, title: string;
begin
  if ChapNo = 0 then    // 初期化されていない
    Exit;
  if (Episode.Chapter <> '') and (Episode.Section <> '') then
    ChapNested := True;
  if Episode.Section = '' then
    title := Episode.Chapter
  else
    title := Episode.Section;
  sl := TStringList.Create;
  try
    s := BODYHEAD + title + BODYMID + Episode.Episode + BODYTAIL;
    sl.Text := s;
    sl.WriteBOM := False;
    sl.SaveToFile(EpubText + '\chap' + IntToStr(ChapNo) + '.xhtml', TEncoding.UTF8);
    // Epub(zip)に保存するファイルリストを準備する
    EpubFiles.Add('"' + EpubText + '\chap' + IntToStr(ChapNo) + '.xhtml",OEBPS/Text/chap' + IntToStr(ChapNo) + '.xhtml');

    Chapter.Add('"' + Episode.Chapter + '","' + Episode.Section + '"');   // 半角スペース等のデリミタ文字が含まれている場合を想定して""で括る
    ChapLbl.Add('Chap' + IntToStr(ChapNo));
    Inc(ChapNo);
  finally
    sl.Free;
  end;
end;

// 挿絵画像（イメージファイル）をEpubフォルダ内に追加する
procedure EpubAddImage(ImageFile: string);
begin
  if DirectoryExists(EpubImage) then
  begin
    CopyFile(PWideChar(ImageFile), PWideChar(EpubImage + '\' + ExtractFileName(ImageFile)), False);
    // Epub(zip)に保存するファイルリストを準備する
    EpubFiles.Add('"' + EpubImage + '\' + ExtractFileName(ImageFile) + '","OEBPS/Images/' + ExtractFileName(ImageFile) + '"');
    Inc(ImageNum);  // 挿絵画像数をカウント
  end;
end;

// 最終処理
// 追加された目次情報からbook.opfとnav.xhtmlファイルを構成して保存し、
// 最後にTZipFileでEPUBファイルを作成する
procedure FinalizeEpub;
var
  opf, nav, ct: TStringList;
  i: integer;
  cn, imglist: string;
  cf: boolean;
  zip: TZipFile;
  zipfile: TStringList;
begin
  if ChapNo = 0 then    // 初期化されていない
    Exit;

  opf := TStringList.Create;
  nav := TStringList.Create;
  ct  := TstringList.Create;
  try
    // opfファイルのヘッダー部分を作成する
    opf.Text := OPFHEAD + Uuid + OPFMID1
              + EpubTitle + OPFMID2       // タイトル名
              + EpubAuther + OPFMID3;     // 作者名
    if EpubPublisher <> '' then           // 発行者
      opf.Text := opf.Text + OPFMID4 + EpubPublisher + OPFMID5;
    opf.Text := Opf.Text + OPFMID6 + CreateTime + OPFMID7;     // Epub作成日時(UTC)
    // 表紙絵があれば表紙用のtitlepage.xhtmlを追加する
    if IsCoverImg then
      opf.Text := Opf.Text + OPFCOVER;
    // navファイルのヘッダー部分を作成する
    // 目次が章と話で構成されている場合は
    //                     <ol>
    // ・表紙                <li><a href="Text/chap1.xhtml">表紙</a></li>
    // ・前書き（あれば）    <li><a href="Text/chap2.xhtml">前書き</a></li>
    // ▷章                  <li><a href="Text/chap4.xhtml">第一章</a>
    //                         <ol>
    //   ・話                    <li><a href="Text/chap4.xhtml">第1話</a></li>
    //   ・話                    <li><a href="Text/chap4.xhtml">第2話</a></li>
    //                         </ol>
    //                       </li>
    //                     </ol>
    // とし、話見出しだけの構成であれば
    //                     <ol>
    // ・表紙                <li><a href="Text/chap1.xhtml">表紙</a></li>
    // ・あらすじ            <li><a href="Text/chap2.xhtml">あらすじ</a></li>
    // ・話                  <li><a href="Text/chap4.xhtml">第1話</a></li>
    // ・話                  <li><a href="Text/chap4.xhtml">第2話</a></li>
    //                     </ol>
    // とする

    nav.Text := NAVHEAD;
    cf := False;
    // 表紙を追加する
    nav.Add(NAVTITLE);
    opf.Add(OPFCHAPL + '1' + OPFCHAPM + '1' + OPFCHAPR);
    for i := 2 to Chapter.Count do
    begin
      cn := IntToStr(i);
      // opfファイルに各話（チャプター）情報を追加する
      opf.Add(OPFCHAPL + cn + OPFCHAPM + cn + OPFCHAPR);
      // navファイルに各話（チャプター）情報を追加する
      ct.CommaText := Chapter[i - 1];
      if ct.Count = 1 then
        ct.Add('');
      // 前書きがある場合
      if (i = 2) and (ct[1] = 'あらすじ')then
        nav.Add(NAVINTRO)
      else begin
        // 表紙または大見出しがある（目次を階層化する）
        if ct[0] <> '' then
        begin
          // 既に大見出し内に入っていれば、前の大見出し階層から抜ける
          if cf then
            nav.Add(NAVSECED);
          // 新しい大見出しの階層に入る
          nav.Add(NAVCHAP1 + cn + NAVCPMID + ct[0] + NAVCPTL1);
          nav.Add(NAVSECBG);
          // Sectionタイトルがない場合はスキップ(2023/1/10)
          if ct[1] <> '' then
            nav.Add(NAVCHAP2 + cn + NAVCPMID + ct[1] + NAVCPTL2);
          cf := True;
        // 中見出しだけを追加
        end else if ct[1] <> '' then
        begin
          nav.Add(NAVCHAP2 + cn + NAVCPMID + ct[1] + NAVCPTL2);
        end;
      end;
    end;
    // opfファイルのページ情報を構築する
    opf.Text := opf.Text + OPFMID8;
    // 表紙絵があればtitlepage.xhtmlへのリンク情報を追加する
    if IsCoverImg then
      opf.Text := opf.Text + OPFIMAGE;
    // 挿絵画像IDを追加する
    for i := 0 to ImageNum - 1 do
    begin
      imglist := OPFIMGLS + IntToStr(i + 1) + OPFIMGLM + IntToStr(i + 1) + OPFIMGLE;
      opf.Add(imglist);
    end;

    opf.Text := opf.Text + OPFMID9;
    // 表紙絵があればtitpepage IDを追加する
    if IsCoverImg then
      opf.Text := opf.Text + OPFMID10;

    for i := 1 to Chapter.Count do
      opf.Add(OPFITEML + IntToStr(i) + OPFITEMR);
    // opf/navファイルのフッター部分を追加する
    opf.Text := opf.Text + OPFTAIL;
    // 大見出しがあれば<li>タグを</li>で閉じる
    if cf then
    begin
      if IsCoverImg then
        nav.Text := nav.Text + NAVSECED + #13#10 + NAVMID + #13#10 + NAVCOVER + NAVTAIL
      else
        nav.Text := nav.Text + NAVSECED + #13#10 + NAVMID + #13#10 + NAVTAIL;
    end else begin
      if IsCoverImg then
        nav.Text := nav.Text + NAVMID + NAVCOVER + NAVTAIL
      else
        nav.Text := nav.Text + NAVMID + NAVTAIL;
    end;

    opf.WriteBOM := False;
    nav.WriteBOM := False;
    opf.SaveToFile(EpubEpub + '\book.opf',  TEncoding.UTF8);
    nav.SaveToFile(EpubEpub + '\nav.xhtml', TEncoding.UTF8);

    // Epub(zip)に保存するファイルリストを準備する
    EpubFiles.Add('"' + EpubEpub + '\book.opf",OEBPS/book.opf');
    EpubFiles.Add('"' + EpubEpub + '\nav.xhtml",OEBPS/nav.xhtml');
    // 表紙画像cover.jpg
    if FileExists(EpubImage + '\cover.jpg') then
      EpubFiles.Add('"' + EpubImage + '\cover.jpg' + '","OEBPS/Images/cover.jpg"');

    // TZipFileを使用してEPUBファイルを構築する
    zip := TZipFile.Create;
    zipfile := TStringList.Create;
    try
      zip.Open(EpubName, zmWrite);
      // mimetypeを無圧縮で格納する
      zipfile.CommaText := EpubFiles[0];
      // mimetypeを最初に無圧縮で格納する
      zip.Add(zipfile[0], zipfile[1], zcStored);
      // その他のファイルを圧縮して格納する
      for i := 1 to EPubFiles.Count - 1 do
      begin
        zipfile.CommaText := EpubFiles[i];
        if FileExists(zipfile[0]) then
          zip.Add(zipfile[0], zipfile[1], zcDeflate);
      end;
      zip.Close;
    finally
      zipfile.Free;
      zip.Free;
    end;
  finally
    opf.Free;
    nav.Free;
    ct.Free;
  end;
end;

// 初期化
initialization
  Chapter     := TStringList.Create;  // 各話情報構築用に生成
  ChapLbl     := TStringList.Create;  // 各話情報構築用に生成
  EpubFiles   := TStringList.Create;  // Epub保存ファイルリスト用に生成
  EpubBase    := '';                  // Epubフォルダ名（ベースディレクトリ\EPUB）
  EpubName    := '';                  // Epubファイル名
  EpubFile    := '';                  // 強制外部指定EPUBファイル名

// TStringListの破棄
finalization
  Chapter.Free;
  ChapLbl.Free;
  EpubFiles.Free;

end.
