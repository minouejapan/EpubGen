program text2Epub;

uses
  Vcl.Forms,
  Text2EpubUnit in 'Text2EpubUnit.pas' {Form1},
  EpubGen in 'EpubGen.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
