program mota;

uses
  Vcl.Forms,
  Unit1 in 'Unit1.pas' {r};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(Tr, r);
  Application.Run;
end.
