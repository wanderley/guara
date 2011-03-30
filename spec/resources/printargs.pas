program printargs;

var
  I: Integer;

begin
  for I := 0 to ParamCount do
    writeln(ParamStr(I))
end.
