(*

  EPUB作成ユニットEpubGenのサンプルアプリケーション

  入力ファイルに拙作Web小説ダウンローダーでダウンロードしたテキストファイルを、
  Epubの場所にEPUBファイルを作成するためのベースディレクトリを指定してEpub作成
  ボタンを押せば、Epubベースディレクトリの下に作品タイトル名を元にしたフォルダ
  を作成して、その下に「作品名.epub」のEPUBファイルが作成される

  あくまでもサンプルプロジェクトであるため、拙作ダウンローダーが吐き出す青空
  文庫（風）タグの一部にしか対応していませんし最低限の処理しか行っていません
  またEpubGen側には表紙絵や挿絵処理がありますが、このサンプルでは挿絵をダウン
  ロードしてEPub内に格納するような処理は行っていません


ライセンス
  フリーソフトです。個人、業務に関わらず、どなたでも自由に使用することが出来ます
  が、使用に当たって発生したいかなる不具合に対してもいっさいの保証はしません。
  尚、ソースコードの流用・改変含めて自由です。

修正履歴
  2922/03/24 EpubGenでTZipFileを使用するように変更したため、zip.exeの場所指定を削除した
             最後の起動状況を保存して次回起動時に復元するようにした（text2Epub.exeと同じ場所に
             text2Epub.iniファイルを作成するので書込み可能なフォルダにtext2Epub.exeを置く必要が
             ある・・・例えばC:\text2Epubフォルダ等）
  2022/02/28 前書きが二重に生成されていた不具合を修正
             HTML特殊文字のエスケープ処理を追加

*)
unit Text2EpubUnit;

interface

uses
{$WARN UNIT_PLATFORM OFF}
	Vcl.FileCtrl,
{$WARN UNIT_PLATFORM ON}
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, System.IniFiles;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Label1: TLabel;
    TxtFile: TEdit;
    Button2: TButton;
    OpenDialog1: TOpenDialog;
    Label2: TLabel;
    EpubDir: TEdit;
    Button3: TButton;
    Label3: TLabel;
    Status: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private 宣言 }
    function PerseText(Text: TStringList; CoverImage: string): Boolean;
  public
    { Public 宣言 }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

uses
  EpubGen;  // EpubGenユニットを使用する

const
  // 青空文庫タグ（拙作テキストダウンローダーが吐き出すもの限定）
  AO_CPI = '［＃「';          // 見出しの開始
  AO_CPT = '」は大見出し］';	// 章
  AO_SEC = '」は中見出し］';  // 話
  AO_CPB = '［＃大見出し］';
  AO_CPE = '［＃大見出し終わり］';
  AO_SEB = '［＃中見出し］';
  AO_SEE = '［＃中見出し終わり］';
  AO_RBI = '｜';							          // ルビのかかり始め
  AO_RBL = '《';                        // ルビ始め
  AO_RBR = '》';                        // ルビ終わり
  AO_PB2 = '［＃改ページ］';	          // ページ送りだが、ここではページ（1話）区切りとして使用する
  AO_EMB = '［＃丸傍点］';              // 丸傍点（強調）開始
  AO_EME = '［＃丸傍点終わり］';        // 丸傍点終わり
  AO_KKL = '［＃ここから罫囲み］' ;     // 本来は罫囲み範囲の指定だが、前書きや後書き等を
  AO_KKR = '［＃ここで罫囲み終わり］';  // 一段小さい文字で表記するために使用する
  AO_PIB = '［＃リンクの図（';          // 画像埋め込み
  AO_PIE = '）入る］';                  // 画像埋め込み終わり
  AO_LIB = '［＃リンク（';              // 画像埋め込み
  AO_LIE = '）入る］';                  // 画像埋め込み終わり
  AO_HR  = '［＃水平線］';              // 水平線<hr />
  AO_CVB = '［＃表紙の図（';            // 表紙画像指定
  AO_CVE = '）入る］';                  // 終わり



// テキスト中のHTML特殊文字をエスケープする
function ReplaceSpecialChar(Text: string): string;
var
  tmp: string;
begin
  Result := '';

  // 特殊文字のエスケープ
  tmp := StringReplace(Text, '&', '&amp;',    [rfReplaceAll]);
  tmp := StringReplace(tmp,  '<', '&lt;',     [rfReplaceAll]);
  tmp := StringReplace(tmp,  '>', '&gt;',     [rfReplaceAll]);
  tmp := StringReplace(tmp,  '"', '&quot;',   [rfReplaceAll]);
  tmp := StringReplace(tmp,  '\', '&yen;',    [rfReplaceAll]);
  tmp := StringReplace(tmp,  '|', '&#166;',   [rfReplaceAll]);
  //エスケープするとエラーになるようなので無効化しておく
  //tmp := StringReplace(tmp,  '©', '&copy;',   [rfReplaceAll]);
  //tmp := StringReplace(tmp,  '®', '&reg;',    [rfReplaceAll]);
  //tmp := StringReplace(tmp,  '°', '&deg;',    [rfReplaceAll]);
  //tmp := StringReplace(tmp,  '±', '&plusmn;', [rfReplaceAll]);
  //tmp := StringReplace(tmp,  '×', '&times;',  [rfReplaceAll]);
  //tmp := StringReplace(tmp,  '÷', '&dvide;',  [rfReplaceAll]);
  //tmp := StringReplace(tmp,  '´', '&acute;',  [rfReplaceAll]);
  //tmp := StringReplace(tmp,  'µ', '&micro;',  [rfReplaceAll]);

  Result := tmp;
end;

// 青空文庫タグをHTMLタグに変換する（見出しと改ページは変換しない）
function ReplaceTags(Text: string): string;
var
  tmp: string;
begin
  Result := '';

  // 一括置換出来るタグ
  tmp := StringReplace(Text, AO_RBI, '<ruby><rb>',              [rfReplaceAll]);
  tmp := StringReplace(tmp,  AO_RBL, '</rb><rp>（</rp><rt>',    [rfReplaceAll]);
  tmp := StringReplace(tmp,  AO_RBR, '</rt><rp>）</rp></ruby>', [rfReplaceAll]);
  tmp := StringReplace(tmp,  AO_EMB, '<em class="ten">',        [rfReplaceAll]);
  tmp := StringReplace(tmp,  AO_EME, '</em>',                   [rfReplaceAll]);
  tmp := StringReplace(tmp,  AO_HR,  '<hr />',                  [rfReplaceAll]);
  tmp := StringReplace(tmp,  AO_PIB, '<a href="リンクの図">',   [rfReplaceAll]);
  tmp := StringReplace(tmp,  AO_PIE, '</a>',                    [rfReplaceAll]);
  tmp := StringReplace(tmp,  AO_LIB, '<a href="URLリンク">',    [rfReplaceAll]);
  tmp := StringReplace(tmp,  AO_LIE, '</a>',                    [rfReplaceAll]);

  Result := tmp;
end;

// テキストを解析してEpubファイルを構築する
function TForm1.PerseText(Text: TStringList; CoverImage: string): Boolean;
var
  title, auther, tmp, c1, c2, chap1, chap2: string;
  i, n: integer;
  page: TStringList;
  ei: TEpubInfo;
  ep: TEpisInfo;
begin
  Result := False;
  title  := Text[0];    // １行目は小説タイトル
  auther := Text[1];    // ２行目は作者名
  tmp    := Text[2];    // ３行目が表紙の図かどうかチェックする
  if Pos(AO_CVB, tmp) > 0 then
    n := 5                      // 表紙の図を飛ばして５行目から解析する
  else
    n := 4;                     // 表紙の図がないため４行目から解析する

  // Epubファイル作成の準備（Publisherは取り敢えず''としてあるが、必要に応じて指定すれば良い）
  ei.BaseDir    := EpubDir.Text;
  ei.Title      := title;
  ei.Auther     := auther;
  ei.Publisher  := '';
  ei.CoverImage := CoverImage;
  InitializeEpub(ei);

  page    := TStringList.Create;;
  try
    // 拙作ダウンローダーが出力する形式に沿って処理する
    // ※タイトル・作者、前書き、各話それぞれの最後にある［＃改ページ］を区切りとする
    // 行単位で解析して［＃改ページ］をトリガーにして各話を分離する
    chap1 := '';
    chap2 := '';
    for i := n to Text.Count - 1 do
    begin
      tmp := ReplaceSpecialChar(Text[i]);

      if Pos(AO_KKL, tmp) > 0 then // 前書き（前書きはタイトルがないので「前書き」をタイトルにする）
      begin
        chap1 := '前書き';
        chap2 := '';
        page.Add('<h3>前書き</h3><br />');
      end else if Pos(AO_CPT, tmp) > 0 then  // 大見出しその１
      begin
        tmp := StringReplace(tmp, AO_CPI, '', [rfReplaceAll]);
        tmp := StringReplace(tmp, AO_CPT, '', [rfReplaceAll]);
        page.Add('<h2>' + tmp + '</h2><br />');
        c1 := tmp;
        chap1 := tmp;
      end else if Pos(AO_SEC, tmp) > 0 then  // 中見出しその１
      begin
        tmp := StringReplace(tmp, AO_CPI, '', [rfReplaceAll]);
        tmp := StringReplace(tmp, AO_SEC, '', [rfReplaceAll]);
        page.Add('<h3>' + tmp + '</h3><br />');
        c2 := tmp;
        if c1 <> '' then
        begin
          chap1 := c1;
          chap2 := c2;
          c1 := '';
        end else begin
          chap1 := '';
          chap2 := c2;
        end;
      end else if Pos(AO_CPB, tmp) > 0 then  // 大見出しその２
      begin
        tmp := StringReplace(tmp, AO_CPB, '', [rfReplaceAll]);
        tmp := StringReplace(tmp, AO_CPE, '', [rfReplaceAll]);
        page.Add('<h2>' + tmp + '</h2><br />');
        c1 := tmp;
      end else if Pos(AO_SEB, tmp) > 0 then  // 中見出しその２
      begin
        tmp := StringReplace(tmp, AO_SEB, '', [rfReplaceAll]);
        tmp := StringReplace(tmp, AO_SEE, '', [rfReplaceAll]);
        page.Add('<h3>' + tmp + '</h3><br />');
        c2 := tmp;
        if c1 <> '' then
        begin
          chap1 := c1;
          chap2 := c2;
          c1 := '';
        end else begin
          chap1 := '';
          chap2 := c2;
        end;
      end else if Pos(AO_KKR, tmp) > 0 then
      begin
        ; // スキップする
      // 改ページを各ページの最後とする
      end else if Pos(AO_PB2, tmp) > 0 then
      begin
        // 青空文庫タグをHTMLタグに変換する
        page.Text := ReplaceTags(page.Text);
        // 分離した１話分を追加する
        ep.Chapter := chap1;
        ep.Section := chap2;
        ep.Episode := page.Text;
        EPubAddPage(ep);
        Application.ProcessMessages;
        page.Clear;
        ep.Chapter := '';
        ep.Section := '';
      end else begin
        page.Add(tmp + '<br />');
      end;
    end;
    // EPUBの最終処理を行う
    FinalizeEpub;
  finally
    page.Free;
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  with OpenDialog1 do
  begin
    Title      := 'テキストファイルを指定する';
    DefaultExt := 'txt';
    Filter     := 'テキストファイル(*.txt)|*.txt|すべてのファイル(*.*)|*.*';
    if FileExists(TxtFile.Text) then
      FileName := TxtFile.Text;
    if Execute then
      TxtFile.Text := FileName;
  end;
end;

procedure TForm1.Button3Click(Sender: TObject);
var
  dir: string;
begin
  if System.SysUtils.DirectoryExists(EpubDir.Text) then
    dir := EpubDir.Text
  else
    dir := '';
  if SelectDirectory('Epubファイルを作成するフォルダを指定', '', dir, [sdNewUI, sdNewFolder]) then
    EpubDir.Text := dir;
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  ini: TInifile;
  inifile: string;
begin
  inifile := ChangeFileExt(Application.ExeName, '.ini');
  ini := TInifile.Create(inifile);
  try
    ini.WriteInteger('setting', 'wintop',  Form1.Top);
    ini.WriteInteger('setting', 'winleft', Form1.Left);
    Ini.WriteString('setting',  'epubdir', EpubDir.Text);
    Ini.WriteString('setting',  'lasttxt', TxtFile.Text);
  finally
    ini.Free;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  ini: TInifile;
  inifile: string;
begin
  inifile := ChangeFileExt(Application.ExeName, '.ini');
  ini := TInifile.Create(inifile);
  try
    Form1.Top    := ini.ReadInteger('setting', 'wintop',  200);
    Form1.Left   := ini.ReadInteger('setting', 'winleft', 400);
    EpubDir.Text := Ini.ReadString('setting',  'epubdir', '');
    TxtFile.Text := Ini.ReadString('setting',  'lasttxt', '');
  finally
    ini.Free;
  end;
end;

// Epub作成
procedure TForm1.Button1Click(Sender: TObject);
var
  coverimg: string;
  txtstr: TStringList;
begin
  if not FileExists(TxtFile.Text) then
  begin
    MessageDlg('Epub変換するテキストファイルを指定して下さい.', mtWarning, [mbOK], 0);
    Exit;
  end;
  if not System.SysUtils.DirectoryExists(EpubDir.Text) then
  begin
    MessageDlg('Epubファイルを作成するフォルダを指定して下さい.', mtWarning, [mbOK], 0);
    Exit;
  end;
  Status.Caption := '作成中...';
  Button1.Enabled := False;
  Application.ProcessMessages;
  // 入力する敵とファイルと同じフォルダにcover.jpgがあれば表紙画像とする
  coverimg := ExtractFilePath(TxtFile.Text) + 'cover.jpg';
  if not FileExists(coverimg) then
    coverimg := '';

  txtstr := TStringList.Create;
  try
    txtstr.LoadFromFile(TxtFile.Text, TEncoding.UTF8);
    // あまりに行数が少ないと流石にWeb小説テキストではないと思われるため処理しない
    if txtstr.Count < 10 then
      MessageDlg('行数が少いため処理を中止します.', mtWarning, [mbOK], 0)
    else
      PerseText(txtstr, coverimg);
  finally
    txtstr.Free;
  end;
  Button1.Enabled := True;
  Status.Caption := '作成しました.'
end;

end.
