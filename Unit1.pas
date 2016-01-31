unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ToolWin, Vcl.ActnMan, Vcl.ActnCtrls,
  Vcl.ActnMenus, Vcl.StdCtrls,PngImage, Vcl.ExtCtrls, Math, StrUtils, mmSystem,
  Vcl.MPlayer;

type
  Tr = class(TForm)
    Map: TImage;
    Timer: TTimer;
    StateMap: TImage;
    Menu: TImage;
    Sound: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TimerTimer(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure SoundTimer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
  public
    procedure MainMenu;
    procedure MenuText(m, n, l, k: Integer);
    procedure CreateMap;
    procedure MonsterMove(p,q,n,s:Integer);
    procedure MapCreate;
    function OpenDoor(p,q:Integer):Boolean;
    procedure ItemMenu;
    procedure Equip;
    procedure GetTxt;
    procedure StartFight;
    procedure FightPrint;
    procedure LifeFlash;
    procedure AttackFlash(n:Integer);
    procedure Attack(n,Turn:Integer);
    function Fight(p,q:Integer): Boolean;
    function GemPicture(n:Integer):TBitMap;
    procedure MsgView(str: String);
    function GemCheck(n, k: Integer): Boolean;
    procedure WallRefresh;
    procedure DestoryWall(p,q:Integer);
    procedure GetWeapon(p, q : Integer);
    procedure StartNum;
    procedure StartCreate;
    procedure GameOver;
    procedure StartSound(m, n: Integer);
    procedure HeroMove(n: Integer);
    procedure SaveGame;
    procedure ReadGame;
    procedure UpFloor;
    procedure DownFloor;
    procedure Walk;
    { Public declarations }
  end;

var
  r: Tr;
  Num: Integer=13;
  BigNum: Integer=3000;
  HardNum: Integer=5;
  Floor: Integer=-10;
  WallNum: Integer=3;
  Time: Integer=0;
  Allow: Boolean = False; //战斗画面区域禁止地图怪物动画
  FightAllow: Boolean = False; //战斗开启
  EquipChance: Boolean = False; //装备栏开启
  EquipChoose: Boolean = False; //装备选择
  EquipOrGem: Boolean = True; //宝石/装备选择
  ItemChance: Boolean = False;
  GemSet: Boolean = False; //宝石镶嵌状态开启/关闭
  GemChoose: Boolean = False; //宝石选择
  GemSpace: Boolean = False;
  LifeChoose: Boolean = False; //生命显示开启
  TimeAllow: Boolean = False;
  KeyAble: Boolean = True;
  MonsterBook: Boolean = False;
  FightQuit: Boolean;
  NumFight, CopyFight: Integer;
  PngFloor,PngWall: TPngImage;
  BmpFight,BmpFight1,BmpFight2: TBitMap;
  BmpLifeBack1,BmpLifeBack2: TBitMap;
  MapArray: Array of Array of Integer;
  NumArray: Array of Array of Integer;
  //HardFloor: Array of Array of Integer;
  FindWayArray,FindNumArray: Array of Integer;
  HardArray: Array of Array of Array of Integer;
  FloorArray: Array of Array of Array of Integer;
  TimeNum: Integer; //时间计数
  GemArray: Array[1..35] of Integer = (101,102,103,104,105,106,{107,}108,109,{110,}111,112,
  {113,}151,152,153,154,155,156,157,158,{159,}201,202,203,204,205,206,{207,}208,{209,210,}
  301,302,303,304,305,306,351,352,353,354);
  ItemArray: Array[1..26] of Integer=(101,102,103,104,107,121,122,123,124,131,132,
  133,151,152,153,154,161,162,163,164,171,172,173,174,175,176);
  MonsterArray: Array[1..44] of Integer=(301,302,303,304,311,312,313,
  314,321,322,323,324,331,332,333,334,351,352,353,361,362,363,371,372,373,401,402,411,
  412,421,422,431,432,441,442,451,452,453,454,455,461,462,463,464);
  DoorArray: Array[1..4] of Integer=(21,22,23,24);
  Item: Array[100..299] of Integer;
  WeaponEquip: Array[1..2] of Integer; //1.武器 2.防具
  //WeaponNum: Array[1..3] of Array[1..7] of Integer; //1..3 position 4.种类 5.名称 6.星级 7.攻击/防御
  WeaponItem: Array[1..24] of Array[1..7] of Integer; //1.排序 2.属性
  //1.种类 2.名称 3.星级 4.攻击/防御 5.宝石1 6.宝石2 7.宝石3
  GemItem: Array[1..28] of Integer;  //宝石栏
  page,pageNum,EquipPage: Integer; //装备页数  选择装备位置  装备选项
  GemNum,GemPage: Integer;
  EquipNum, GemNumber: Integer;
  xHero,yHero,kHero: Integer;
  HeroFace: Integer;
  MoveChance: Boolean = True; //移动许可
  MoveAllow: Boolean;
  HitChance: Boolean; //
  LifeLost: Boolean; //损失或增加生命
  LifeTime: Integer; //显示生命数字次数
  LifeNumber1,LifeNumber2: Integer; //损失或增加生命值
  LifeBack: Array[0..1] of Integer;
  HeroState: Array[1..18] of Integer; //英雄属性
  MonsterState: Array[1..18] of Integer; //怪物属性
  FightArray: Array[0..1] of Array[1..18] of Integer;
  FightNum: Array[0..1] of Array[1..17] of Integer;
  HeroStart: Array[1..18] of Integer=(2000,500,20,20,20,20,0,0,0,0,0,0,100,0,20,0,0,0);
  MonsterStart: Array[1..18] of Integer=(50,10,40,10,30,10,0,0,0,0,0,0,100,0,10,1,1,0);
  MonsterRead: Array[1..18] of Integer; //读取怪物参数
  MonsterBase: Array[1..18] of Integer; //怪物基准属性
  Wall: Integer = 3;
  MsgBmp: TBitmap;
  MsgLock: Integer = 0;
  FindFloor: Integer = 0;
  BookPage: Integer;
  BookPageMax: Integer;
  BookFloor: Integer = 0;
  MenuNum: Integer = 1;
  MenuChoose: Boolean = True;
  FightMenuNum: Integer = 1;
  FightMenu: Boolean = False;
  AttackChoose: Integer; //攻击效果类型
  BackMusic: Integer = 0;
  MoveKey: Integer;
  Over: Boolean;
  SaveTime: Integer;
  {3.墙 4.石头 5.岩浆 15.地面(53.54.55) 21-24门 101-199.物品 301-499.怪物}

implementation

{$R *.dfm}


function SkillName(n:Integer):String;forward;

procedure MapStart;
var
  i: Integer;
begin
  SetLength(MapArray,Num+2);
  SetLength(NumArray,Num+2);
  for i := 0 to Num+1 do
  begin
    SetLength(MapArray[i],Num+2);
    SetLength(NumArray[i],Num+2);
  end;
end;

procedure MapClear;
var
  i,j: Integer;
begin
  for i := 0 to Num+1 do
    for j := 0 to Num+1 do
      MapArray[i,j]:=0;
  for i := 0 to Num+1 do
  begin
    MapArray[0,i]:=WallNum;
    MapArray[i,0]:=WallNum;
    MapArray[Num+1,i]:=WallNum;
    MapArray[i,Num+1]:=WallNum;
  end;
end;

procedure NumClear;
var
  i,j: Integer;
begin
  for i := 0 to Num+1 do
    for j := 0 to Num+1 do
      NumArray[i,j]:=0;
  for i := 0 to Num+1 do
  begin
    NumArray[0,i]:=WallNum;
    NumArray[i,0]:=WallNum;
    NumArray[Num+1,i]:=WallNum;
    NumArray[i,Num+1]:=WallNum;
  end;
end;

procedure FloorStart;
var
  i,j:Integer;
begin
  SetLength(FloorArray,Num+2);
  for i := 0 to Num+1 do
  begin
    SetLength(FloorArray[i],Num+2);
    for j := 0 to Num+1 do
      SetLength(FloorArray[i,j],10);
  end;
end;

procedure AllStart;
var
  i,j,k:Integer;
begin
  MapStart;
  FloorStart;
  SetLength(FindWayArray,Num*Num);
  SetLength(FindNumArray,Num*Num);
  SetLength(HardArray,2);
  for i := 0 to 1 do
  begin
    SetLength(HardArray[i],10);
    for j := 0 to 9 do
    begin
      SetLength(HardArray[i,j],Num*Num);
      for k := 0 to Num*Num-1 do
        HardArray[i,j,k]:=0;
    end;
  end;
end;

function FloorHard:Integer;
begin
  Result:=Trunc(Sqrt(Trunc(Floor/10)+1));
end;

procedure Delay(MSecs: Longint);//延时函数，MSecs单位为毫秒(千分之1秒)
var
  FirstTickCount, Now: Longint;
begin
  FirstTickCount := GetTickCount();
  repeat
    Application.ProcessMessages;
    Now := GetTickCount();
  until (Now - FirstTickCount >= MSecs) or (Now < FirstTickCount);
end;

procedure FloorPoint; //楼梯确定
var
  i,p,q,s:Integer;
begin
  for i := 1 to 2 do
  begin
    while True do
    begin
      p:=Random(Num)+1;
      q:=Random(Num)+1;
      if MapArray[p,q]<>0 then continue;
      s:=0;
      if MapArray[p-1,q]=WallNum then s:=s+1;
      if MapArray[p+1,q]=WallNum then s:=s+1;
      if MapArray[p,q-1]=WallNum then s:=s+1;
      if MapArray[p,q+1]=WallNum then s:=s+1;
      if s=3 then break;
    end;
    MapArray[p,q]:=i;
  end;
end;

procedure CopyFloor(k:Integer);
var
  i,j:Integer;
begin
  for i := 0 to Num+1 do
    for j := 0 to Num+1 do
      MapArray[i,j]:=FloorArray[k,i,j];
end;

procedure CopyMap(k:Integer);
var
  i,j:Integer;
begin
  for i := 0 to Num+1 do
    for j := 0 to Num+1 do
      FloorArray[k,i,j]:=MapArray[i,j];
end;

procedure CopyNum(m,n:Integer);
var
  i,j:Integer;
begin
  for i := 0 to Num+1 do
    for j := 0 to Num+1 do
      if (MapArray[i,j]>m-1)And(MapArray[i,j]<n+1) then NumArray[i,j]:=MapArray[i,j]
end;

function RanNum(m,n:Integer):Integer;
var
  i, s, t: Integer;
begin
  if m < 1 then m := 1;
  repeat
    if n > 0 then
    begin
      s := 0;
      t := m * m + 100;
      for i := 1 to t do s := s + Random(3);
      s := (n * s) div t;
      m := m - n + s;
    end;
  until (m < 1)Or(m > 10);
  Result := m;
end;

function Number(m:Integer):Integer;
var
  i,j,n:Integer;
begin
  n:=0;
  for i := 1 to Num do
    for j := 1 to Num do
      if MapArray[i,j]=m then n:=n+1;
  Result:=n;
end;

function BesideMap(i,j,m:Integer):Integer;
var
  s:Integer;
begin
  s:=0;
  if MapArray[i-1,j]=m then s:=s+1;
  if MapArray[i+1,j]=m then s:=s+1;
  if MapArray[i,j-1]=m then s:=s+1;
  if MapArray[i,j+1]=m then s:=s+1;
  Result:=s;
end;

function BesideNum(i,j,m:Integer):Integer;
var
  s:Integer;
begin
  s:=0;
  if NumArray[i-1,j]=m then s:=s+1;
  if NumArray[i+1,j]=m then s:=s+1;
  if NumArray[i,j-1]=m then s:=s+1;
  if NumArray[i,j+1]=m then s:=s+1;
  Result:=s;
end;

function LineLong(p,q,t:Integer):Integer; //墙长度
var
  i,k,m:Integer;
begin
  m:=0;
  k:=t-1;
  for i := 1 to k do
    m:=m+Random(2);
  k:=Random(t-m)+m;
  m:=0;
  for i := 1 to k do
    m:=m+Random(2);
  Result:=m;
end;

procedure PointDraw; //初始散点
var
  i,m:Integer;
begin
  m:=0;
  for i := 1 to Num do
    m:=m+Random(2);
  m:=m-Trunc(Num/2);
  if m>0 then
  begin
    for i := 1 to m do
    MapArray[Random(Num)+1,Random(Num)+1]:=WallNum;
  end;
end;

procedure LineDraw(p,q,s:Integer); //画一面墙
var
  i,m,k,t:Integer;
begin
  t:=0;
  m:=0;
  case s of
  0:
  begin
    k:=p-1;
    while m=0 do
    begin
      for i := 1 to 3 do
      if MapArray[k,q+i-2]<>0 then m:=1;
      if m=0 then
      begin
        t:=t+1;
        if k=0 then break;
        k:=k-1;
      end;
    end;
    if t>1 then
    begin
      m:=LineLong(p-1,q,t);
      for i := 1 to m do MapArray[p-i,q]:=WallNum;
    end;
  end;
  1:
  begin
    k:=p+1;
    while m=0 do
    begin
      for i := 1 to 3 do
      if MapArray[k,q+i-2]<>0 then m:=1;
      if m=0 then
      begin
        t:=t+1;
        if k=Num-1 then break;
        k:=k+1;
      end;
    end;
    if t>1 then
    begin
      m:=LineLong(p+1,q,t);
      for i := 1 to m do MapArray[p+i,q]:=WallNum;
    end;
  end;
  2:
  begin
    k:=q-1;
    while m=0 do
    begin
      for i := 1 to 3 do
      if MapArray[p+i-2,k]<>0 then m:=1;
      if m=0 then
      begin
        t:=t+1;
        if k=0 then break;
        k:=k-1;
      end;
    end;
    if t>1 then
    begin
      m:=LineLong(p,q-1,t);
      for i := 1 to m do MapArray[p,q-i]:=WallNum;
    end;
  end;
  3:
  begin
    k:=q+1;
    while m=0 do
    begin
      for i := 1 to 3 do
      if MapArray[p+i-2,k]<>0 then m:=1;
      if m=0 then
      begin
        t:=t+1;
        if k=Num-1 then break;
        k:=k+1;
      end;
    end;
    if t>1 then
    begin
      m:=LineLong(p,q+1,t);
      for i := 1 to m do MapArray[p,q+i]:=WallNum;
    end;
  end;
  end;
end;

procedure WallCreat; //画所有墙
var
  p,q,r,s: Integer;
begin
  PointDraw;
  for r :=1 to (Num+2)*(Num+2)*(Num+2) do
  begin
    p:=Random(Num+2);
    q:=Random(Num+2);
    s:=Random(4);
    if ((p=Num+1)And(s<>0))Or((p=0)And(s<>1))Or((q=Num+1)And(s<>2))Or((q=0)And(s<>3)) then
    continue;
    if MapArray[p,q]<>0 then LineDraw(p,q,s);
  end;
end;

procedure OffSetWall; // 某一特殊墙面的修改
var
  i,j,s,t:Integer;
begin
  for i := 2 to Num-1 do
    for j := 2 to Num-1 do
    begin
      if MapArray[i,j]<>0 then continue;
      s:=0;
      if MapArray[i-1,j]<>0 then
      begin
        if MapArray[i-1,j-1]<>0 then continue;
        if MapArray[i-1,j+1]<>0 then continue;
        t:=0;
        s:=s+1;
      end;
      if MapArray[i+1,j]<>0 then
      begin
        if MapArray[i+1,j-1]<>0 then continue;
        if MapArray[i+1,j+1]<>0 then continue;
        t:=1;
        s:=s+1;
      end;
      if MapArray[i,j-1]<>0 then
      begin
        if MapArray[i-1,j-1]<>0 then continue;
        if MapArray[i+1,j-1]<>0 then continue;
        t:=2;
        s:=s+1;
      end;
      if MapArray[i,j+1]<>0 then
      begin
        if MapArray[i-1,j+1]<>0 then continue;
        if MapArray[i+1,j+1]<>0 then continue;
        t:=3;
        s:=s+1;
      end;
      if s<>1 then continue;
      s:=0;
      if MapArray[i-1,j-1]<>0 then s:=s+1;
      if MapArray[i-1,j+1]<>0 then s:=s+1;
      if MapArray[i+1,j-1]<>0 then s:=s+1;
      if MapArray[i+1,j+1]<>0 then s:=s+1;
      if s<>2 then continue;
      case t of
      0:
      begin
        if MapArray[i+2,j-1]=0 then
        begin
          MapArray[i+1,j-1]:=0;
          MapArray[i+1,j]:=WallNum;
        end
        else if MapArray[i+2,j+1]=0 then
        begin
          MapArray[i+1,j+1]:=0;
          MapArray[i+1,j]:=WallNum;
        end;
      end;
      1:
      begin
        if MapArray[i-2,j-1]=0 then
        begin
          MapArray[i-1,j-1]:=0;
          MapArray[i-1,j]:=WallNum;
        end
        else if MapArray[i-2,j+1]=0 then
        begin
          MapArray[i-1,j+1]:=0;
          MapArray[i-1,j]:=WallNum;
        end;
      end;
      2:
      begin
        if MapArray[i-1,j+2]=0 then
        begin
          MapArray[i-1,j+1]:=0;
          MapArray[i,j+1]:=WallNum;
        end
        else if MapArray[i+1,j+2]=0 then
        begin
          MapArray[i+1,j+1]:=0;
          MapArray[i,j+1]:=WallNum;
        end;
      end;
      3:
      begin
        if MapArray[i-1,j-2]=0 then
        begin
          MapArray[i-1,j-1]:=0;
          MapArray[i,j-1]:=WallNum;
        end
        else if MapArray[i+1,j-2]=0 then
        begin
          MapArray[i+1,j-1]:=0;
          MapArray[i,j-1]:=WallNum;
        end;
      end;
      end;
    end;
end;

function OffSetSpace:Boolean; //区格填充，使之没有方块形
var
  i,j,k,s:Integer;
  t:Boolean;
begin
  for k := 0 to Num*Num do
  begin
    for i := 1 to Num-1 do
      for j := 1 to Num-1 do
      begin
        s:=0;
        if MapArray[i,j]=0 then s:=s+1;
        if MapArray[i,j+1]=0 then s:=s+1;
        if MapArray[i+1,j]=0 then s:=s+1;
        if MapArray[i+1,j+1]=0 then s:=s+1;
        if s<>4 then continue;
        t:=False;
        if (MapArray[i-1,j]<>0)And(MapArray[i,j-1]<>0) then
        begin
          MapArray[i,j]:=10;
          t:=True;
          continue;
        end;
        if (MapArray[i-1,j+1]<>0)And(MapArray[i,j+2]<>0) then
        begin
          MapArray[i,j+1]:=10;
          t:=True;
          continue;
        end;
        if (MapArray[i+1,j-1]<>0)And(MapArray[i+2,j]<>0) then
        begin
          MapArray[i+1,j]:=10;
          t:=True;
          continue;
        end;
        if (MapArray[i+2,j+1]<>0)And(MapArray[i+1,j+2]<>0) then
        begin
          MapArray[i+1,j+1]:=10;
          t:=True;
          continue;
        end;
      end;
    if Not t then break;
  end;
  Result:=t;
end;

function MainWay(p,q,t,n:Integer):Integer; //找主路径
var
  i,j,k,m,s:Integer;
  Label endMainWay;
begin
  s:=1;
  while s<>0 do
  begin
    case t of
    0: p:=p-1;
    1: p:=p+1;
    2: q:=q-1;
    3: q:=q+1;
    end;
    if MapArray[p,q]=2 then
    begin
      Result:=1;
      break;
    end;
    if (MapArray[p-1,q]=2)Or(MapArray[p+1,q]=2)
    Or(MapArray[p,q-1]=2)Or(MapArray[p,q+1]=2) then
    begin
      MapArray[p,q]:=12;
      Result:=1;
      break;
    end;
    s:=0;
    if MapArray[p-1,q]<>0 then s:=s+1
    else t:=0;
    if MapArray[p+1,q]<>0 then s:=s+1
    else t:=1;
    if MapArray[p,q-1]<>0 then s:=s+1
    else t:=2;
    if MapArray[p,q+1]<>0 then s:=s+1
    else t:=3;
    case s of
    1..2:
    begin
      MapArray[p,q]:=n;
      while True do
      begin
        m:=2;
        case Random(4) of
        0:
        if (MapArray[p-1,q]=0)Or(MapArray[p-1,q]=2) then m:=MainWay(p,q,0,n+1);
        1:
        if (MapArray[p+1,q]=0)Or(MapArray[p+1,q]=2) then m:=MainWay(p,q,1,n+1);
        2:
        if (MapArray[p,q-1]=0)Or(MapArray[p,q-1]=2) then m:=MainWay(p,q,2,n+1);
        3:
        if (MapArray[p,q+1]=0)Or(MapArray[p,q+1]=2) then m:=MainWay(p,q,3,n+1);
        end;
        if m=0 then
        begin
          for i := 1 to Num do
            for j := 1 to Num do
              if (MapArray[i,j]>10)And(MapArray[i,j]<20) then MapArray[i,j]:=0;
          Result:=0;
          goto endMainWay;
        end;
        if m=1 then
        begin
          for i := 1 to Num do
            for j := 1 to Num do
              if MapArray[i,j]=n+1 then MapArray[i,j]:=12;
          Result:=1;
          goto endMainWay;
        end;
      end;
    end;
    3: MapArray[p,q]:=n;
    4:
    begin
      Result:=0;
      break;
    end;
    end;
  end;
  endMainWay:
  if Result<>1 then Result:=0;
end;

function FindWay(pSign:Integer):Integer; //确定树枝型路径
var
  i,j,k,p,q,s,t:Integer;
begin
  for k := 0 to Num*Num do
  begin
    s:=0;
    for i := 1 to Num do
    begin
      for j := 1 to Num do
      begin
        if MapArray[i,j]<>0 then continue;
        s:=0;
        if MapArray[i-1,j]>2 then s:=s+1;
        if MapArray[i+1,j]>2 then s:=s+1;
        if MapArray[i,j-1]>2 then s:=s+1;
        if MapArray[i,j+1]>2 then s:=s+1;
        if s>2 then break;
      end;
      if s>2 then break;
    end;
    if s<3 then break
    else
    begin
      p:=i;
      q:=j;
      while (s>2)And(MapArray[p,q]=0) do
      begin
        MapArray[p,q]:=pSign;
        if MapArray[p-1,q]=0 then p:=p-1;
        if MapArray[p+1,q]=0 then p:=p+1;
        if MapArray[p,q-1]=0 then q:=q-1;
        if MapArray[p,q+1]=0 then q:=q+1;
        s:=0;
        if (MapArray[p-1,q]>2)And(MapArray[p-1,q]<>12) then s:=s+1;
        if (MapArray[p+1,q]>2)And(MapArray[p+1,q]<>12) then s:=s+1;
        if (MapArray[p,q-1]>2)And(MapArray[p,q-1]<>12) then s:=s+1;
        if (MapArray[p,q+1]>2)And(MapArray[p,q+1]<>12) then s:=s+1;
      end;
      pSign:=pSign+1;
    end;
  end;
  Result:=pSign;
end;

procedure FindAllWay; //路径确定和区块划分
var
  i,j,k,m,n,p,q,t:Integer;
  pSign:Integer;
  Label reFindWay,FindOut;
begin
  pSign:=FindWay(20);
  for i := 1 to Num do
  begin
    for j := 1 to Num do
    begin
      if MapArray[i,j]=1 then break;
    end;
    if MapArray[i,j]=1 then break;
  end;
  if MapArray[i-1,j]=0 then t:=0;
  if MapArray[i+1,j]=0 then t:=1;
  if MapArray[i,j-1]=0 then t:=2;
  if MapArray[i,j+1]=0 then t:=3;
  p:=i;
  q:=j;
  reFindWay:
  while MainWay(p,q,t,12)=0 do;
  for i := 1 to Num do
    for j := 1 to Num do
    if MapArray[p,q]=12 then
      if BesideMap(p,q,12)=3 then goto reFindWay;
  t:=1;
  while t=1 do
  begin
    t:=0;
    for i := 1 to Num do
      for j := 1 to Num do
        if MapArray[i,j]=0 then
        begin
          pSign:=FindWay(pSign);
          MapArray[i,j]:=pSign;
          t:=1;
          pSign:=pSign+1;
          goto FindOut;
        end;
    FindOut:
  end;
  for k := 20 to pSign do
  begin
    m:=0;
    n:=0;
    for i := 1 to Num do
      for j := 1 to Num do
        if MapArray[i,j]=k then
        begin
          m:=m+1;
          if BesideMap(i,j,3)<3 then n:=n+1;
        end;
    if (m=1)And(n=1) then
    begin
      for i := 1 to Num do
      begin
        for j := 1 to Num do
          if MapArray[i,j]=k then break;
        if MapArray[i,j]=k then break;
      end;
      if (MapArray[i-1,j]>19)And(MapArray[i-1,j]<pSign+1) then MapArray[i,j]:=MapArray[i-1,j];
      if (MapArray[i+1,j]>19)And(MapArray[i+1,j]<pSign+1) then MapArray[i,j]:=MapArray[i+1,j];
      if (MapArray[i,j-1]>19)And(MapArray[i,j-1]<pSign+1) then MapArray[i,j]:=MapArray[i,j-1];
      if (MapArray[i,j+1]>19)And(MapArray[i,j+1]<pSign+1) then MapArray[i,j]:=MapArray[i,j+1];
    end;
  end;
end;

procedure BackSpace;
var
  i,j,k,s,t:Integer;
begin
  CopyNum(1,3);
  for k := 0 to Num*Num do
  begin
    t:=0;
    for i := 1 to Num-1 do
      for j := 1 to Num-1 do
      begin
        s:=0;
        if (NumArray[i,j]=0)Or(NumArray[i,j]=10) then s:=s+1;
        if (NumArray[i,j+1]=0)Or(NumArray[i,j+1]=10) then s:=s+1;
        if (NumArray[i+1,j]=0)Or(NumArray[i+1,j]=10) then s:=s+1;
        if (NumArray[i+1,j+1]=0)Or(NumArray[i+1,j+1]=10) then s:=s+1;
        if s<>4 then continue;
        s:=0;
        if NumArray[i,j]=10 then s:=s+1;
        if NumArray[i,j+1]=10 then s:=s+1;
        if NumArray[i+1,j]=10 then s:=s+1;
        if NumArray[i+1,j+1]=10 then s:=s+1;
        if s<>4 then t:=t+1;
        NumArray[i,j]:=10;
        NumArray[i,j+1]:=10;
        NumArray[i+1,j]:=10;
        NumArray[i+1,j+1]:=10;
      end;
    if t=0 then break;
  end;
end;

{procedure SolveWay;
var
  i,j,k,m,n,l,nMax,s,t:Integer;
  MaxArray:Array of Integer;
  Label AgainSolve;
begin
  t:=1;
  for k := 1 to 9 do
    t:=t+Random(2);
  for i := 0 to Num*Num-1 do FindWayArray[i]:=-1;
  s:=0;
  for i := 0 to 9 do
    for j := 1 to t do
    begin
      m:=i;
      for k := 1 to t do
        if Random(2)=0 then m:=m-1
        else m:=m+1;
      if (m>-1)And(m<10) then
      begin
        FindWayArray[s]:=m;
        s:=s+1;
      end;
    end;
  for i := 0 to Num*Num-1 do FindNumArray[i]:=0;
  for n := 0 to 9 do
  begin
    CopyFloor(n);
    if Number(0)>0 then FindAllWay;
    CopyMap(n);
    for l := 0 to Num*Num do
    begin
      if FindWayArray[l]=-1 then break;
      if FindWayArray[l]<>n then continue;
      nMax:=0;
      for i := 1 to Num do
        for j := 1 to Num do
          if MapArray[i,j]>nMax then nMax:=MapArray[i,j];
      SetLength(MaxArray,nMax-19);
      AgainSolve:
      for i := 0 to nMax-20 do
        MaxArray[i]:=0;
      for k := 0 to nMax-20 do
      begin
        while True do
        begin
          s:=20+Random(nMax-19);
          if MaxArray[k]=0 then break;
        end;
        MaxArray[k]:=1;
        t:=0;
        for i := 1 to Num do
          for j := 1 to Num do
          begin
            if MapArray[i,j]<>s then continue;
            if MapArray[i-1,j]=12 then t:=1;
            if MapArray[i+1,j]=12 then t:=1;
            if MapArray[i,j-1]=12 then t:=1;
            if MapArray[i,j+1]=12 then t:=1;
          end;
        if (t=1)And(Number(s)>0) then
        begin
          FindNumArray[l]:=s;
          for i := 1 to Num do
            for j := 1 to Num do
              if MapArray[i,j]=s then MapArray[i,j]:=12;
          break;
        end;
        if k=nMax-20 then goto AgainSolve;
      end;
    end;
  end;
end; }

procedure AllSet;
var
  i,j,m,p,q,s,sta:Integer;
  b:Boolean;
begin
  BackSpace;
  //两个相邻的的方块
  for i := 1 to Num do //被3夹着的变11
    for j := 1 to Num do
    begin
      m:=MapArray[i,j];
      if m<4 then continue;
      if (MapArray[i-1,j]=3)And(MapArray[i+1,j]=3) then
      begin
        if (MapArray[i,j-1]=m)And(MapArray[i,j+1]<>3) then NumArray[i,j]:=11;
        if (MapArray[i,j+1]=m)And(MapArray[i,j-1]<>3) then NumArray[i,j]:=11;
      end;
      if (MapArray[i,j-1]=3)And(MapArray[i,j+1]=3) then
      begin
        if (MapArray[i-1,j]=m)And(MapArray[i+1,j]<>3) then NumArray[i,j]:=11;
        if (MapArray[i+1,j]=m)And(MapArray[i-1,j]<>3) then NumArray[i,j]:=11;
      end;
    end;
  for i := 1 to Num do //被3夹着且周围有10的变12
    for j := 1 to Num do
    if (NumArray[i,j]>3)Or(NumArray[i,j]=0) then
    begin
      if BesideMap(i,j,3)<>2 then continue;
      if (NumArray[i-1,j]=3)And(NumArray[i+1,j]=3) then
      begin
        if NumArray[i,j-1]=10 then NumArray[i,j]:=12;
        if NumArray[i,j+1]=10 then NumArray[i,j]:=12;
      end;
      if (NumArray[i,j-1]=3)And(NumArray[i,j+1]=3) then
      begin
        if NumArray[i-1,j]=10 then NumArray[i,j]:=12;
        if NumArray[i+1,j]=10 then NumArray[i,j]:=12;
      end;
    end;
  for i := 1 to Num do //12边上的10变13或14
    for j := 1 to Num do
    begin
      if NumArray[i,j]<>10 then continue;
      if MapArray[i,j]=10 then NumArray[i,j]:=14;
      if BesideNum(i,j,12)>0 then
      begin
        if (NumArray[i-1,j-1]=13)Or(NumArray[i-1,j+1]=13) then
        begin
          NumArray[i,j]:=14;
          continue;
        end;
        case Random(3) of
          0..1: NumArray[i,j]:=13;
          2: NumArray[i,j]:=14;
        end;
      end;
    end;
  b:=True;
  while b do //10边上有2个3和14或被3和14包围 ，10变14
  begin
    for i := 1 to Num do
      for j := 1 to Num do
      begin
        if NumArray[i,j]<>10 then continue;
        if (BesideNum(i,j,3)=2)And(BesideNum(i,j,14)>0)Or((BesideNum(i,j,3)+BesideNum(i,j,10))=14) then
        begin
          NumArray[i,j]:=14;
          b:=True;
        end;
      end;
    b:=False;
  end;
  for i := 1 to Num do //10边上有0，将10变14，0变13
    for j := 1 to Num do
    begin
      if NumArray[i,j]<>10 then continue;
      if BesideNum(i,j,0)>0 then
      begin
        NumArray[i,j]:=14;
        if NumArray[i-1,j]=0 then NumArray[i-1,j]:=13;
        if NumArray[i+1,j]=0 then NumArray[i+1,j]:=13;
        if NumArray[i,j-1]=0 then NumArray[i,j-1]:=13;
        if NumArray[i,j+1]=0 then NumArray[i,j+1]:=13;
      end;
    end;
  for i := 1 to Num do //角落的变14,
    for j := 1 to Num do
    begin
      if NumArray[i,j]<>0 then continue;
      if BesideNum(i,j,3)=3 then
      begin
        NumArray[i,j]:=14;
        sta:=NumArray[i,j];
        p:=i;
        q:=j;
        m:=0;
        while True do
        begin
          if BesideNum(p,q,11)=1 then
          begin
            if NumArray[p-1,q]=11 then p:=p-1;
            if NumArray[p+1,q]=11 then p:=p+1;
            if NumArray[p,q-1]=11 then q:=q-1;
            if NumArray[p,q+1]=11 then q:=q+1;
            if NumArray[p,q]=11 then
            begin
              s:=Random(4)+12;
              if (s<>sta) then s:=Random(4)+12;
              sta:=s;
              NumArray[p,q]:=sta;
            end;
            m:=m+1;
            continue;
          end;
          if NumArray[p,q]=11 then
          begin
            if Random(Trunc(Sqrt(m))+m)>0 then NumArray[p,q]:=12
            else NumArray[p,q]:=13;
          end;
          break;
        end;
      end;
    end;
  for i := 1 to Num do //剩余10
    for j := 1 to Num do
    begin
      if NumArray[i,j]<>10 then continue;
      if Random(2)=0 then NumArray[i,j]:=13 else NumArray[i,j]:=14;
    end;
  for i := 1 to Num do
    for j := 1 to Num do
    begin
      if NumArray[i,j]<>11 then continue;
      case BesideNum(i,j,12) of
        0: continue;
        1:
        begin
          if NumArray[i-1,j]=12 then
          begin
            if NumArray[i-2,j]=13 then NumArray[i,j]:=15;
            if NumArray[i-2,j]=14 then
            begin
              if Random(3)=0 then NumArray[i,j]:=15 else NumArray[i,j]:=13;
            end;
          end;
          if NumArray[i+1,j]=12 then NumArray[i+1,j]:=13;
          begin
            if NumArray[i+2,j]=13 then NumArray[i,j]:=15;
            if NumArray[i+2,j]=14 then
            begin
              if Random(3)=0 then NumArray[i,j]:=15 else NumArray[i,j]:=13;
            end;
          end;
          if NumArray[i,j-1]=12 then NumArray[i,j-1]:=13;
          begin
            if NumArray[i,j-2]=13 then NumArray[i,j]:=15;
            if NumArray[i,j-2]=14 then
            begin
              if Random(3)=0 then NumArray[i,j]:=15 else NumArray[i,j]:=13;
            end;
          end;
          if NumArray[i,j+1]=12 then NumArray[i,j+1]:=13;
          begin
            if NumArray[i,j+2]=13 then NumArray[i,j]:=15;
            if NumArray[i,j+2]=14 then
            begin
              if Random(3)=0 then NumArray[i,j]:=15 else NumArray[i,j]:=13;
            end;
          end;
        end;
        2: if Random(2)=0 then NumArray[i,j]:=15 else NumArray[i,j]:=13;
      end;
    end;
  for i := 1 to Num do //剩余0
    for j := 1 to Num do
    begin
      if NumArray[i,j]<>0 then continue;
      if BesideNum(i,j,0)=0 then
      begin
        NumArray[i,j]:=15;
        continue;
      end;
      case Random(100) of
        0..49: NumArray[i,j]:=15;
        50..79: NumArray[i,j]:=13;
        80..99: NumArray[i,j]:=14;
      end;
    end;
  for i := 1 to Num do //剩余11
    for j := 1 to Num do
    begin
      if NumArray[i,j]<>11 then continue;
      if BesideNum(i,j,11)<>0 then
      case Random(100) of
        0..69: NumArray[i,j]:=15;
        70..79: NumArray[i,j]:=12;
        80..89: NumArray[i,j]:=13;
        90..99: NumArray[i,j]:=14;
      end
      else
      case Random(100) of
        0..69: NumArray[i,j]:=15;
        70..84: NumArray[i,j]:=12;
        85..94: NumArray[i,j]:=13;
        95..99: NumArray[i,j]:=14;
      end;
    end;
end;

{procedure HardWay;
var
  i,j,k,l,m,n,nMain:Integer;
  b:Boolean;
begin
  for k := 0 to 9 do
  begin
    CopyFloor(k);
    if Number(0)>0 then FindAllWay;
  end;
  b:=False;
  while Not(b) do
  begin
    SolveWay;
    for l := 0 to 9 do
    begin
      b:=False;
      for k := 0 to Num*Num-1 do
      begin
        if FindWayArray[k]=-1 then continue;
        if FindWayArray[k]=l then b:=True;
      end;
      if Not(b) then break;
    end;
  end;
  nMain:=0;
  for i := 0 to Num*Num-1 do
    if FindNumArray[i]<>0 then nMain:=nMain+1;
  m:=(RanNum(6,1)+RanNum(6,2)) div 2;
  for i := 0 to nMain-1 do
  begin
    n:=i+1;
    HardArray[1,FindWayArray[i],FindNumArray[i]]:=RanNum((n*m) div nMain,1);
  end;
  for l := 0 to 9 do
  begin
    CopyFloor(l);
    for k := 20 to Num*Num do
    begin
      m:=0;
      for i := 1 to Num do
        for j := 1 to Num do
        begin
          if MapArray[i,j]<>k then continue;
          if NumArray[i-1,j]=12 then m:=m+1;
          if NumArray[i+1,j]=12 then m:=m+1;
          if NumArray[i,j-1]=12 then m:=m+1;
          if NumArray[i,j+1]=12 then m:=m+1;
        end;
      if (m=2)And(Number(k)<4) then HardArray[1,l,k]:=RanNum(9-n,2);
    end;
    b:=True;
    for k := 0 to Num*Num-1 do
    begin
      if Not(b) then break;
      b:=False;
      if FindWayArray[k]=l then
      begin
        b:=True;
        for i := 1 to Num do
          for j := 1 to Num do
          begin
            if MapArray[i,j]<>12 then continue;
            HardArray[1,l,12]:=HardArray[1,l,FindNumArray[k]];
          end;
      end;
    end;

  end;
end; }

{procedure HardMap(l:Integer);
var
  i,j,k,m,s:Integer;
begin
  for i := 1 to Num do
    for j := 1 to Num do
      HardFloor[i,j]:=0;
  m:=(RanNum(HardNum,5)+(Floor mod 10)) div 2;
  for i := 1 to Num do
    for j := 1 to Num do
    begin
      if MapArray[i,j]<4 then
      begin
        HardFloor[i,j]:=15;
        continue;
      end;
      if HardArray[1,l,MapArray[i,j]]<>0 then
        HardFloor[i,j]:=RanNum((HardArray[1,l,MapArray[i,j]]+m),1) div 2;
    end;
  k:=1;
  while k>0 do
  begin
    for i := 1 to Num do
      for j := 1 to Num do
      begin
        if HardFloor[i,j]=15 then continue;
        if HardFloor[i-1,j]<>15 then HardFloor[i,j]:=RanNum(HardFloor[i-1,j],Random(3));
        if HardFloor[i+1,j]<>15 then HardFloor[i,j]:=RanNum(HardFloor[i+1,j],Random(3));
        if HardFloor[i,j-1]<>15 then HardFloor[i,j]:=RanNum(HardFloor[i,j-1],Random(3));
        if HardFloor[i,j+1]<>15 then HardFloor[i,j]:=RanNum(HardFloor[i,j+1],Random(3));
      end;
    k:=0;
    for i := 1 to Num do
      for j := 1 to Num do
        if HardFloor[i,j]=0 then k:=k+1;
  end;
  for i := 1 to Num do
    for j := 1 to Num do
      if (HardFloor[i,j]<>0)And(HardFloor[i,j]<>15) then
      begin
        HardFloor[i,j]:=HardFloor[i,j]+Trunc(Sqrt(l));
        if HardFloor[i,j]<1 then HardFloor[i,j]:=1;
        if HardFloor[i,j]>10 then HardFloor[i,j]:=10;
      end;
end;}

function ItemNum(p,q,s:Integer):Integer;
var
  m,n,t:Integer;
begin
  case s of
    1: n:=Random(26) + 1;
    2: n:=Random(44) + 1;
    3: n:=Random(4) + 1;
  end;
  case s of
    1: Result:=ItemArray[n];
    2: Result:=MonsterArray[n];
    3: Result:=DoorArray[n];
  end;
end;

function SetNum(m, n: Integer): Integer;
var
  i, j, k: Integer;
begin
  repeat
    i := Random(Num) + 1;
    j := Random(Num) + 1;
    k := Random(10);
  until FloorArray[k, i, j] = m;
  FloorArray[k, i, j] := n;
  Result := k + 1;
end;


procedure MapSet; //Door 12, Monster 13, Item 14
var
  Door, Monster, Item: Array[0..10] of Integer;
  DoorNum: Array[0..4] of Integer;
  GemNum: Array[0..4] of Integer;
  PotionNum: Array[0..4] of Integer;
  i, j, k, l: Integer;
  m, n: Integer;
begin
  for k := 1 to 10 do
  begin
    Door[k] := 0;
    Monster[k] := 0;
    Item[k] := 0;
    for i := 1 to Num do
      for j := 1 to Num do
      case FloorArray[k - 1][i][j] of
        12: Door[k] := Door[k] + 1;
        13: Monster[k] := Monster[k] + 1;
        14: Item[k] := Item[k] + 1;
      end;
  end;
  Door[0] := 0;
  Monster[0] := 0;
  Item[0] := 0;
  for i := 1 to 10 do
  begin
    Door[0] := Door[0] + Door[i];
    Monster[0] := Monster[0] + Monster[i];
    Item[0] := Item[0] + Item[i];
  end;

  DoorNum[0] := Door[0] * 9 div 10;
  DoorNum[1] := DoorNum[0] div 10 * 6;
  DoorNum[2] := DoorNum[0] div 10 * 3;
  DoorNum[3] := DoorNum[0] div 10 * 1;
  DoorNum[4] := DoorNum[0] - DoorNum[1] - DoorNum[2] - DoorNum[3];
  n := DoorNum[3] div 5;
  DoorNum[1] := DoorNum[1] - n;
  DoorNum[2] := DoorNum[2] - n;
  DoorNum[3] := DoorNum[3] - n;
  while n > 0 do
  begin
    k := SetNum(14, 107);
    Item[0] := Item[0] - 1;
    Item[k] := Item[k] - 1;
    n := n -1;
  end;
  for i := 4 downto 1 do
  begin
    n := DoorNum[i];
    while n > 0 do
    begin
      k := SetNum(14, 100 + i);
      Item[0] := Item[0] - 1;
      Item[k] := Item[k] - 1;
      n := n -1;
    end;
  end;

  DoorNum[0] := Door[0];
  DoorNum[1] := DoorNum[0] div 10 * 6;
  DoorNum[2] := DoorNum[0] div 10 * 3;
  DoorNum[3] := DoorNum[0] - DoorNum[1] - DoorNum[2];
  for i := 3 downto 1 do
  begin
    n := DoorNum[i];
    while n > 0 do
    begin
      k := SetNum(12, 20 + i);
      Door[0] := Door[0] - 1;
      Door[k] := Door[k] - 1;
      n := n - 1;
    end;
  end;

  GemNum[0] := Item[0] div 3;
  n := GemNum[0];
  GemNum[1] := 0;
  GemNum[2] := 0;
  GemNum[3] := 0;
  GemNum[4] := 0;
  for n := 1 to GemNum[0] do
    case Random(100) of
      0..29: GemNum[1] := GemNum[1] + 1;
      30..59: GemNum[2] := GemNum[2] + 1;
      60..79: GemNum[3] := GemNum[3] + 1;
      80..99: GemNum[4] := GemNum[4] + 1;
    end;
  for i := 1 to 4 do
  begin
    n := GemNum[i];
    while n > 0 do
    begin
      k := SetNum(14, 150 + i);
      Item[0] := Item[0] - 1;
      Item[k] := Item[k] - 1;
      n := n - 1;
    end;
  end;
  MonsterBase[3] := MonsterBase[3] + GemNum[1] * FloorHard;
  MonsterBase[4] := MonsterBase[4] + GemNum[2] * FloorHard;
  MonsterBase[5] := MonsterBase[5] + GemNum[3] * FloorHard;
  MonsterBase[6] := MonsterBase[6] + GemNum[4] * FloorHard;

  PotionNum[0] := Item[0];
  n := PotionNum[0];
  PotionNum[1] := 0;
  PotionNum[2] := 0;
  PotionNum[3] := 0;
  PotionNum[4] := 0;
  for n := 1 to PotionNum[0] do
    case Random(100) of
      0..29: PotionNum[1] := PotionNum[1] + 1;
      30..59: PotionNum[2] := PotionNum[2] + 1;
      60..79: PotionNum[3] := PotionNum[3] + 1;
      80..99: PotionNum[4] := PotionNum[4] + 1;
    end;
  for i := 1 to 4 do
  begin
    n := PotionNum[i];
    while n > 0 do
    begin
      k := SetNum(14, 160 + i);
      Item[0] := Item[0] - 1;
      Item[k] := Item[k] - 1;
      n := n - 1;
    end;
  end;

  //WeaponNum[1] ;
  //Weapon Item Key Gem Potion
  //ShowMessage(IntToStr(Door[0]) + ' ' + IntToStr(Monster[0]) + ' ' + IntToStr(Item[0]));
end;

procedure Tr.CreateMap;
var
  i,j,k:Integer;
begin
  Wall := 3 + Random(3);
  WallRefresh;
  for k := 0 to 9 do
  begin
    while True do
    begin
    MapClear;
    WallCreat;
    OffSetWall;
    if OffSetSpace then break;
    end;
    FloorPoint;
    CopyMap(k);
  end;
  //HardWay;
  for k := 0 to 9 do
  begin
    CopyFloor(k);
    NumClear;
    AllSet;
    //HardMap(k);
    for i := 1 to Num do
      for j := 1 to Num do
      begin
        if (MapArray[i,j]=1)And(k=0) then
        begin
          MapArray[i,j]:=15;
          xHero:=i;
          yHero:=j;
          kHero:=0;
        end
        else MapArray[i,j]:=NumArray[i,j];
      end;
    CopyMap(k);
  end;
  MapSet;
  for i := 1 to 44 do
    if MonsterArray[i] = 176 then ShowMessage(IntToStr(i));
  for k := 0 to 9 do
    for i := 1 to Num do
      for j := 1 to Num do
      begin
        if FloorArray[k,i,j]=12 then
        FloorArray[k,i,j]:=ItemNum(i,j,3);
        if FloorArray[k,i,j]=13 then
        FloorArray[k,i,j]:=ItemNum(i,j,2);
        if FloorArray[k,i,j]=14 then
        FloorArray[k,i,j]:=ItemNum(i,j,1);
      end;
  Floor:=Floor+10-(Floor Mod 10);
  FindFloor := 0;
end;

procedure SoundStop(s: String);
begin
  MCISendString(PChar('STOP ' + s), nil, 0, 0);
end;

procedure SoundPlay(s: String; t: String = '.wav');
begin
  MCISendString(PChar('OPEN .\music\' + s + t + ' Alias ' + s), nil, 0, 0);
  MCISendString(PChar('SEEK ' + s + ' TO START'), nil, 0, 0);
  MCISendString(PChar('PLAY ' + s), nil, 0, 0);
  MCISendString('CLOSE ANIMATION', nil, 0, 0);
  //ShowMessage('Sound');
end;

procedure Tr.StartSound(m, n: Integer);
begin
  BackMusic := m;
  Sound.Interval := n * 1000;
  case m of
    1: SoundPlay('FrontSound', '.mp3');
    2: SoundPlay('BackSound', '.mp3');
  end;
end;

procedure Tr.MenuText(m, n, l, k: Integer);
var
  i: Integer;
begin
  if l = 0 then Menu.Canvas.Font.Color:=clwhite
  else Menu.Canvas.Font.Color:=clred;
  Menu.Canvas.Font.Name:='楷体';
  Menu.Canvas.Font.Size:=14;
  Menu.Canvas.Font.Style:=[fsBold, fsItalic];
  Menu.canvas.Brush.style:=bsclear;
  case k of
  1:
  begin
    Menu.Canvas.TextOut(m, n, '开');
    Menu.Canvas.TextOut(m + 31, n - 6, '始');
    Menu.Canvas.TextOut(m + 31 * 2, n - 6 * 2, '游');
    Menu.Canvas.TextOut(m + 31 * 3, n - 6 * 3, '戏');
  end;
  2:
  begin
    Menu.Canvas.TextOut(m, n, '游');
    Menu.Canvas.TextOut(m + 31, n - 6, '戏');
    Menu.Canvas.TextOut(m + 31 * 2, n - 6 * 2, '说');
    Menu.Canvas.TextOut(m + 31 * 3, n - 6 * 3, '明');
  end;
  3:
  begin
    Menu.Canvas.TextOut(m, n, '离');
    Menu.Canvas.TextOut(m + 31, n - 6, '开');
    Menu.Canvas.TextOut(m + 31 * 2, n - 6 * 2, '游');
    Menu.Canvas.TextOut(m + 31 * 3, n - 6 * 3, '戏');
  end;
  end;
end;

procedure Tr.MainMenu;
var
  Png: TPngImage;
begin

  Menu.Visible := True;
  Png := TPngImage.Create;
  //MenuChoose := True;
  Png.LoadFromFile(getcurrentdir() + '\data\BackScreen\1.png');
  Menu.Canvas.Draw(0, 0, Png);
  Png.LoadFromFile(getcurrentdir() + '\data\BackScreen\2.png');
  Menu.Canvas.Draw(100, 50, Png);
  Png.LoadFromFile(getcurrentdir() + '\data\BackScreen\11.png');
  Menu.Canvas.Draw(246, 197, Png);
  if MenuNum <> 1 then
  begin
    Png.LoadFromFile(getcurrentdir() + '\data\BackScreen\21.png');
    Menu.Canvas.Draw(246, 217, Png);
    MenuText(246 + 14, 217 + 39, 0, 1);
  end
  else
  begin
    Png.LoadFromFile(getcurrentdir() + '\data\BackScreen\22.png');
    Menu.Canvas.Draw(246, 217, Png);
    MenuText(246 + 14, 217 + 39, 1, 1);
  end;
  if MenuNum <> 2 then
  begin
    Png.LoadFromFile(getcurrentdir() + '\data\BackScreen\21.png');
    Menu.Canvas.Draw(246, 273, Png);
    MenuText(246 + 14, 273 + 39, 0, 2);
  end
  else
  begin
    Png.LoadFromFile(getcurrentdir() + '\data\BackScreen\22.png');
    Menu.Canvas.Draw(246, 273, Png);
    MenuText(246 + 14, 273 + 39, 1, 2);
  end;
  if MenuNum <> 3 then
  begin
    Png.LoadFromFile(getcurrentdir() + '\data\BackScreen\21.png');
    Menu.Canvas.Draw(246, 329, Png);
    MenuText(246 + 14, 329 + 39, 0, 3);
  end
  else
  begin
    Png.LoadFromFile(getcurrentdir() + '\data\BackScreen\22.png');
    Menu.Canvas.Draw(246, 329, Png);
    MenuText(246 + 14, 329 + 39, 1, 3);
  end;
  //MenuNum
  Png.Free;
end;

function MapItem(n:Integer):TPngImage;
var
  Png:TPngImage;
begin
  Png:=TPngImage.Create;
  case n of
  101: Png.LoadFromFile(getcurrentdir() + '\data\Item\101.png');
  102: Png.LoadFromFile(getcurrentdir() + '\data\Item\102.png');
  103: Png.LoadFromFile(getcurrentdir() + '\data\Item\103.png');
  104: Png.LoadFromFile(getcurrentdir() + '\data\Item\104.png');
  105: Png.LoadFromFile(getcurrentdir() + '\data\Item\105.png');
  106: Png.LoadFromFile(getcurrentdir() + '\data\Item\106.png');
  107: Png.LoadFromFile(getcurrentdir() + '\data\Item\107.png');
  111: Png.LoadFromFile(getcurrentdir() + '\data\Item\111.png');
  112: Png.LoadFromFile(getcurrentdir() + '\data\Item\112.png');
  113: Png.LoadFromFile(getcurrentdir() + '\data\Item\113.png');
  121: Png.LoadFromFile(getcurrentdir() + '\data\Item\121.png');
  122: Png.LoadFromFile(getcurrentdir() + '\data\Item\122.png');
  123: Png.LoadFromFile(getcurrentdir() + '\data\Item\123.png');
  124: Png.LoadFromFile(getcurrentdir() + '\data\Item\124.png');
  131: Png.LoadFromFile(getcurrentdir() + '\data\Item\131.png');
  132: Png.LoadFromFile(getcurrentdir() + '\data\Item\132.png');
  133: Png.LoadFromFile(getcurrentdir() + '\data\Item\133.png');
  141: Png.LoadFromFile(getcurrentdir() + '\data\Item\141.png');
  142: Png.LoadFromFile(getcurrentdir() + '\data\Item\142.png');
  143: Png.LoadFromFile(getcurrentdir() + '\data\Item\143.png');
  144: Png.LoadFromFile(getcurrentdir() + '\data\Item\144.png');
  151: Png.LoadFromFile(getcurrentdir() + '\data\Item\151.png');
  152: Png.LoadFromFile(getcurrentdir() + '\data\Item\152.png');
  153: Png.LoadFromFile(getcurrentdir() + '\data\Item\153.png');
  154: Png.LoadFromFile(getcurrentdir() + '\data\Item\154.png');
  161: Png.LoadFromFile(getcurrentdir() + '\data\Item\161.png');
  162: Png.LoadFromFile(getcurrentdir() + '\data\Item\162.png');
  163: Png.LoadFromFile(getcurrentdir() + '\data\Item\163.png');
  164: Png.LoadFromFile(getcurrentdir() + '\data\Item\164.png');
  171: Png.LoadFromFile(getcurrentdir() + '\data\Item\171.png');
  172: Png.LoadFromFile(getcurrentdir() + '\data\Item\172.png');
  173: Png.LoadFromFile(getcurrentdir() + '\data\Item\173.png');
  174: Png.LoadFromFile(getcurrentdir() + '\data\Item\174.png');
  175: Png.LoadFromFile(getcurrentdir() + '\data\Item\175.png');
  176: Png.LoadFromFile(getcurrentdir() + '\data\Item\176.png');
  181: Png.LoadFromFile(getcurrentdir() + '\data\Item\181.png');
  182: Png.LoadFromFile(getcurrentdir() + '\data\Item\182.png');
  201: Png.LoadFromFile(getcurrentdir() + '\data\Item\201.png');
  202: Png.LoadFromFile(getcurrentdir() + '\data\Item\202.png');
  203: Png.LoadFromFile(getcurrentdir() + '\data\Item\203.png');
  204: Png.LoadFromFile(getcurrentdir() + '\data\Item\204.png');
  205: Png.LoadFromFile(getcurrentdir() + '\data\Item\205.png');
  211: Png.LoadFromFile(getcurrentdir() + '\data\Item\211.png');
  212: Png.LoadFromFile(getcurrentdir() + '\data\Item\212.png');
  213: Png.LoadFromFile(getcurrentdir() + '\data\Item\213.png');
  214: Png.LoadFromFile(getcurrentdir() + '\data\Item\214.png');
  215: Png.LoadFromFile(getcurrentdir() + '\data\Item\215.png');
  221: Png.LoadFromFile(getcurrentdir() + '\data\Item\221.png');
  222: Png.LoadFromFile(getcurrentdir() + '\data\Item\222.png');
  223: Png.LoadFromFile(getcurrentdir() + '\data\Item\223.png');
  224: Png.LoadFromFile(getcurrentdir() + '\data\Item\224.png');
  225: Png.LoadFromFile(getcurrentdir() + '\data\Item\225.png');
  231: Png.LoadFromFile(getcurrentdir() + '\data\Item\231.png');
  232: Png.LoadFromFile(getcurrentdir() + '\data\Item\232.png');
  233: Png.LoadFromFile(getcurrentdir() + '\data\Item\233.png');
  234: Png.LoadFromFile(getcurrentdir() + '\data\Item\234.png');
  235: Png.LoadFromFile(getcurrentdir() + '\data\Item\235.png');
  end;
  Result:=Png;
end;

function MapMonster(n:Integer):TPngImage;
var
  Png:TPngImage;
begin
  Png:=TPngImage.Create;
  case n of
  301: Png.LoadFromFile(getcurrentdir() + '\data\Monster\301.png');
  302: Png.LoadFromFile(getcurrentdir() + '\data\Monster\302.png');
  303: Png.LoadFromFile(getcurrentdir() + '\data\Monster\303.png');
  304: Png.LoadFromFile(getcurrentdir() + '\data\Monster\304.png');
  311: Png.LoadFromFile(getcurrentdir() + '\data\Monster\311.png');
  312: Png.LoadFromFile(getcurrentdir() + '\data\Monster\312.png');
  313: Png.LoadFromFile(getcurrentdir() + '\data\Monster\313.png');
  314: Png.LoadFromFile(getcurrentdir() + '\data\Monster\314.png');
  321: Png.LoadFromFile(getcurrentdir() + '\data\Monster\321.png');
  322: Png.LoadFromFile(getcurrentdir() + '\data\Monster\322.png');
  323: Png.LoadFromFile(getcurrentdir() + '\data\Monster\323.png');
  324: Png.LoadFromFile(getcurrentdir() + '\data\Monster\324.png');
  331: Png.LoadFromFile(getcurrentdir() + '\data\Monster\331.png');
  332: Png.LoadFromFile(getcurrentdir() + '\data\Monster\332.png');
  333: Png.LoadFromFile(getcurrentdir() + '\data\Monster\333.png');
  334: Png.LoadFromFile(getcurrentdir() + '\data\Monster\334.png');
  351: Png.LoadFromFile(getcurrentdir() + '\data\Monster\351.png');
  352: Png.LoadFromFile(getcurrentdir() + '\data\Monster\352.png');
  353: Png.LoadFromFile(getcurrentdir() + '\data\Monster\353.png');
  361: Png.LoadFromFile(getcurrentdir() + '\data\Monster\361.png');
  362: Png.LoadFromFile(getcurrentdir() + '\data\Monster\362.png');
  363: Png.LoadFromFile(getcurrentdir() + '\data\Monster\363.png');
  371: Png.LoadFromFile(getcurrentdir() + '\data\Monster\371.png');
  372: Png.LoadFromFile(getcurrentdir() + '\data\Monster\372.png');
  373: Png.LoadFromFile(getcurrentdir() + '\data\Monster\373.png');
  401: Png.LoadFromFile(getcurrentdir() + '\data\Monster\401.png');
  402: Png.LoadFromFile(getcurrentdir() + '\data\Monster\402.png');
  411: Png.LoadFromFile(getcurrentdir() + '\data\Monster\411.png');
  412: Png.LoadFromFile(getcurrentdir() + '\data\Monster\412.png');
  421: Png.LoadFromFile(getcurrentdir() + '\data\Monster\421.png');
  422: Png.LoadFromFile(getcurrentdir() + '\data\Monster\422.png');
  431: Png.LoadFromFile(getcurrentdir() + '\data\Monster\431.png');
  432: Png.LoadFromFile(getcurrentdir() + '\data\Monster\432.png');
  441: Png.LoadFromFile(getcurrentdir() + '\data\Monster\441.png');
  442: Png.LoadFromFile(getcurrentdir() + '\data\Monster\442.png');
  451: Png.LoadFromFile(getcurrentdir() + '\data\Monster\451.png');
  452: Png.LoadFromFile(getcurrentdir() + '\data\Monster\452.png');
  453: Png.LoadFromFile(getcurrentdir() + '\data\Monster\453.png');
  454: Png.LoadFromFile(getcurrentdir() + '\data\Monster\454.png');
  455: Png.LoadFromFile(getcurrentdir() + '\data\Monster\455.png');
  461: Png.LoadFromFile(getcurrentdir() + '\data\Monster\461.png');
  462: Png.LoadFromFile(getcurrentdir() + '\data\Monster\462.png');
  463: Png.LoadFromFile(getcurrentdir() + '\data\Monster\463.png');
  464: Png.LoadFromFile(getcurrentdir() + '\data\Monster\464.png');
  end;
  Result:=Png;
end;

procedure Tr.MonsterMove(p,q,n,s:Integer);
var
  Png:TPngImage;
  Bmp:TBitMap;
  t,hNum:Integer;
begin
  Png:=TPngImage.Create;
  Bmp:=TBitMap.Create;
  case n of
  301: Png.LoadFromFile(getcurrentdir() + '\data\Action\021.png');
  302: Png.LoadFromFile(getcurrentdir() + '\data\Action\021.png');
  303: Png.LoadFromFile(getcurrentdir() + '\data\Action\021.png');
  304: Png.LoadFromFile(getcurrentdir() + '\data\Action\021.png');
  311: Png.LoadFromFile(getcurrentdir() + '\data\Action\022.png');
  312: Png.LoadFromFile(getcurrentdir() + '\data\Action\022.png');
  313: Png.LoadFromFile(getcurrentdir() + '\data\Action\022.png');
  314: Png.LoadFromFile(getcurrentdir() + '\data\Action\031.png');
  321: Png.LoadFromFile(getcurrentdir() + '\data\Action\023.png');
  322: Png.LoadFromFile(getcurrentdir() + '\data\Action\023.png');
  323: Png.LoadFromFile(getcurrentdir() + '\data\Action\023.png');
  324: Png.LoadFromFile(getcurrentdir() + '\data\Action\031.png');
  331: Png.LoadFromFile(getcurrentdir() + '\data\Action\027.png');
  332: Png.LoadFromFile(getcurrentdir() + '\data\Action\027.png');
  333: Png.LoadFromFile(getcurrentdir() + '\data\Action\030.png');
  334: Png.LoadFromFile(getcurrentdir() + '\data\Action\027.png');
  351: Png.LoadFromFile(getcurrentdir() + '\data\Action\025.png');
  352: Png.LoadFromFile(getcurrentdir() + '\data\Action\029.png');
  353: Png.LoadFromFile(getcurrentdir() + '\data\Action\025.png');
  361: Png.LoadFromFile(getcurrentdir() + '\data\Action\024.png');
  362: Png.LoadFromFile(getcurrentdir() + '\data\Action\024.png');
  363: Png.LoadFromFile(getcurrentdir() + '\data\Action\029.png');
  371: Png.LoadFromFile(getcurrentdir() + '\data\Action\026.png');
  372: Png.LoadFromFile(getcurrentdir() + '\data\Action\026.png');
  373: Png.LoadFromFile(getcurrentdir() + '\data\Action\026.png');
  401: Png.LoadFromFile(getcurrentdir() + '\data\Action\025.png');
  402: Png.LoadFromFile(getcurrentdir() + '\data\Action\025.png');
  411: Png.LoadFromFile(getcurrentdir() + '\data\Action\024.png');
  412: Png.LoadFromFile(getcurrentdir() + '\data\Action\029.png');
  421: Png.LoadFromFile(getcurrentdir() + '\data\Action\024.png');
  422: Png.LoadFromFile(getcurrentdir() + '\data\Action\031.png');
  431: Png.LoadFromFile(getcurrentdir() + '\data\Action\026.png');
  432: Png.LoadFromFile(getcurrentdir() + '\data\Action\029.png');
  441: Png.LoadFromFile(getcurrentdir() + '\data\Action\023.png');
  442: Png.LoadFromFile(getcurrentdir() + '\data\Action\027.png');
  451: Png.LoadFromFile(getcurrentdir() + '\data\Action\028.png');
  452: Png.LoadFromFile(getcurrentdir() + '\data\Action\030.png');
  453: Png.LoadFromFile(getcurrentdir() + '\data\Action\030.png');
  454: Png.LoadFromFile(getcurrentdir() + '\data\Action\028.png');
  455: Png.LoadFromFile(getcurrentdir() + '\data\Action\030.png');
  461: Png.LoadFromFile(getcurrentdir() + '\data\Action\022.png');
  462: Png.LoadFromFile(getcurrentdir() + '\data\Action\028.png');
  463: Png.LoadFromFile(getcurrentdir() + '\data\Action\028.png');
  464: Png.LoadFromFile(getcurrentdir() + '\data\Action\031.png');
  end;
  case n of
  301: t:=1;
  302: t:=2;
  303: t:=3;
  304: t:=4;
  311: t:=1;
  312: t:=2;
  313: t:=3;
  314: t:=3;
  321: t:=1;
  322: t:=2;
  323: t:=3;
  324: t:=2;
  331: t:=2;
  332: t:=3;
  333: t:=4;
  334: t:=4;
  351: t:=1;
  352: t:=1;
  353: t:=2;
  361: t:=1;
  362: t:=2;
  363: t:=4;
  371: t:=1;
  372: t:=2;
  373: t:=3;
  401: t:=3;
  402: t:=4;
  411: t:=4;
  412: t:=3;
  421: t:=3;
  422: t:=4;
  431: t:=1;
  432: t:=2;
  441: t:=4;
  442: t:=1;
  451: t:=2;
  452: t:=3;
  453: t:=2;
  454: t:=1;
  455: t:=1;
  461: t:=4;
  462: t:=3;
  463: t:=4;
  464: t:=1;
  end;
  s:=s-1;
  t:=t-1;
  hNum:=32*32;
  Bmp.Width:=32;
  Bmp.Height:=32;
  Map.Canvas.Draw(hNum,hNum,PngFloor);
  Map.Canvas.Draw(hNum-32*s,hNum-32*t,Png);
  Bmp.Canvas.CopyRect(Rect(0,0,32,32),Map.Canvas,Rect(hNum,hNum,hNum+32,hNum+32));
  Map.Canvas.Draw(p,q,Bmp);
  Png.Free;
  Bmp.Free;
end;

procedure Tr.MapCreate;
var
  i,j,hNum:Integer;
  Png:TPngImage;
  Bmp:TBitMap;
begin
  //WallRefresh;
  CopyFloor(kHero);
  Png:=TPngImage.Create;
  Bmp:=TBitMap.Create;
  Bmp.Width:=32;
  Bmp.Height:=32;
  hNum:=32*32;
  Map.Width:=Num*32+hNum;
  Map.Height:=Num*32+hNum;
  for i := 1 to Num do
    for j := 1 to Num do
      Map.Canvas.Draw(32*(i-1),32*(j-1),PngFloor);
  for i := 1 to Num do
    for j := 1 to Num do
    begin
      if (MapArray[i,j]=1)Or(MapArray[i,j]=2) then
      begin
        Png.LoadFromFile(getcurrentdir() + '\data\magictower.png');
        Map.Canvas.Draw(hNum,hNum,PngFloor);
        Map.Canvas.Draw(hNum-32*(MapArray[i,j]-1),hNum-32*31,Png);
        Bmp.Canvas.CopyRect(Rect(0,0,32,32),Map.Canvas,Rect(hNum,hNum,hNum+32,hNum+32));
        Map.Canvas.Draw(32*(i-1),32*(j-1),Bmp);
      end;
      if MapArray[i,j]=3 then Map.Canvas.Draw(32*(i-1),32*(j-1),PngWall);
      if MapArray[i,j]=15 then Map.Canvas.Draw(32*(i-1),32*(j-1),PngFloor);
      if (MapArray[i,j]>20)And(MapArray[i,j]<30) then
      begin
        Png.LoadFromFile(getcurrentdir() + '\data\Action\Door.png');
        Map.Canvas.Draw(hNum,hNum,PngFloor);
        Map.Canvas.Draw(hNum-32*(MapArray[i,j]-21),hNum,Png);
        Bmp.Canvas.CopyRect(Rect(0,0,32,32),Map.Canvas,Rect(hNum,hNum,hNum+32,hNum+32));
        Map.Canvas.Draw(32*(i-1),32*(j-1),Bmp);
      end;
      if (MapArray[i,j]>100)And(MapArray[i,j]<300) then
      begin
        //Png.LoadFromFile(getcurrentdir() + '\data\001.png');
        Map.Canvas.Draw(32*(i-1),32*(j-1),PngFloor);
        Png:=MapItem(MapArray[i,j]);
        Map.Canvas.Draw(32*(i-1),32*(j-1),Png);
      end;
    end;
  Map.Canvas.Draw(hNum,hNum,PngFloor);
  if (kHero<>0)Or(MapArray[xHero,yHero]<>1) then
  begin
    Png.LoadFromFile(getcurrentdir() + '\data\magictower.png');
    Map.Canvas.Draw(hNum-32*(MapArray[xHero,yHero]-1),hNum-32*31,Png);
  end;
  Png.LoadFromFile(getcurrentdir() + '\data\Action\011.png');
  Map.Canvas.Draw(hNum,hNum,Png);
  Bmp.Canvas.CopyRect(Rect(0,0,32,32),Map.Canvas,Rect(hNum,hNum,hNum+32,hNum+32));
  Map.Canvas.Draw(32*(xHero-1),32*(yHero-1),Bmp);
  Map.Width:=Num*32;
  Map.Height:=Num*32;
  Timer.Enabled:=True;
  Png.Free;
  Bmp.Free;
end;

function Tr.OpenDoor(p,q:Integer):Boolean;
var
  k,hNum:Integer;
  Png:TPngImage;
  Bmp:TBitMap;
begin
  Png:=TPngImage.Create;
  Bmp:=TBitMap.Create;
  hNum:=32*32;
  Bmp.Width:=32;
  Bmp.Height:=32;
  Png.LoadFromFile(getcurrentdir() + '\data\Action\Door.png');
  if (MapArray[p,q] >= 21)And(MapArray[p,q] <= 23) then
  begin
    if Item[MapArray[p,q] + 80]=0 then
    begin
      if Item[104] = 0 then
      begin
        Result:=False;
        exit;
      end;
      Item[104] := Item[104] - 1;
    end
    else Item[MapArray[p,q] + 80] := Item[MapArray[p,q] + 80] - 1;
    for k := 0 to 3 do
    begin
      Map.Canvas.Draw(hNum,hNum,PngFloor);
      Map.Canvas.Draw(hNum-32*(MapArray[p,q] - 21),hNum-32*k,Png);
      Bmp.Canvas.CopyRect(Rect(0,0,32,32),Map.Canvas,Rect(hNum,hNum,hNum+32,hNum+32));
      Map.Canvas.Draw(32*(p-1),32*(q-1),Bmp);
      Delay(50);
    end;
    Map.Canvas.Draw(32*(p-1),32*(q-1),PngFloor);
    MapArray[p,q]:=15;
    Result:=True;
  end
  else Result := False;
  SoundPlay('OpenDoor');
end;

procedure GetItem(p,q:Integer);
begin
  case MapArray[p,q] of
  101..104: Item[MapArray[p,q]]:=Item[MapArray[p,q]]+1;
  107:
  begin
    Item[101] := Item[101] + 1;
    Item[102] := Item[102] + 1;
    Item[103] := Item[103] + 1;
  end;
  121: HeroState[16]:=HeroState[16]+FloorHard*100;
  131..133: Item[MapArray[p,q]]:=Item[MapArray[p,q]]+1;
  151..154: HeroState[MapArray[p,q]-148]:=HeroState[MapArray[p,q]-148]+FloorHard;
  161: HeroState[1]:=HeroState[1]+FloorHard*100;
  162: HeroState[2]:=HeroState[2]+FloorHard*50;
  163: HeroState[1]:=HeroState[1]+FloorHard*300;
  164: HeroState[2]:=HeroState[2]+FloorHard*150;
  end;
  MapArray[p,q]:=15;
  SoundPlay('GetItem');
end;

procedure Tr.ItemMenu;
var
  Png:TPngImage;
  Bmp:TBitMap;
  i, j, k, l, n, Att1, Att2, s:Integer;
  BookArray: Array[300..500] of Integer;
  str:String;
begin
  Png:=TPngImage.Create;
  Bmp:=TBitMap.Create;
  Png.LoadFromFile(getcurrentdir() + '\data\001.png');
  for i := 0 to 6 do
    for j := 0 to Num do
      StateMap.Canvas.Draw(32*i,32*j,Png);
  if FightMenu then
  begin
    StateMap.Canvas.Font.Name:='楷体';
    StateMap.Canvas.Font.Size:=14;
    StateMap.Canvas.Font.Style:=[fsBold];
    StateMap.Canvas.Brush.style:=bsclear;
    if FightMenuNum <> 1 then StateMap.Canvas.Font.Color:=clwhite
    else StateMap.Canvas.Font.Color:=clyellow;
    StateMap.Canvas.TextOut(40, 24, '返 回 游 戏');
    if FightMenuNum <> 2 then StateMap.Canvas.Font.Color:=clwhite
    else StateMap.Canvas.Font.Color:=clyellow;
    StateMap.Canvas.TextOut(40, 24 + 32, '储 存 档 案');
    if FightMenuNum <> 3 then StateMap.Canvas.Font.Color:=clwhite
    else StateMap.Canvas.Font.Color:=clyellow;
    StateMap.Canvas.TextOut(40, 24 + 32 * 2, '读 取 档 案');
    if FightMenuNum <> 4 then StateMap.Canvas.Font.Color:=clwhite
    else StateMap.Canvas.Font.Color:=clyellow;
    StateMap.Canvas.TextOut(40, 24 + 32 * 3, '退 出 游 戏');
    exit;
  end;

  if MonsterBook then
  begin
    StateMap.Canvas.Font.Color:=clwhite;
    StateMap.Canvas.Font.Name:='楷体';
    StateMap.Canvas.Font.Size:=12;
    StateMap.Canvas.Font.Style:=[fsBold];
    StateMap.canvas.Brush.style:=bsclear;
    StateMap.Canvas.TextOut(32*2,8,'怪物手册');
    StateMap.Canvas.Font.Size:=8;
    for i := 300 to 500 do BookArray[i] := 0;
    for i := 1 to Num do
      for j := 1 to Num do
      begin
        if (MapArray[i][j] > 300)And(MapArray[i][j] < 500) then
        begin
          if BookArray[MapArray[i][j]] <> 0 then continue;
          BookArray[MapArray[i][j]] := 1;
        end
        else continue;
      end;
    if BookFloor <> Floor then
    begin
      BookPage := 0;
      BookFloor := Floor;
    end;
    BookPageMax := 0;
    for i := 300 to 500 do if BookArray[i] <> 0 then BookPageMax := BookPageMax + 1;
    BookPageMax := Ceil(BookPageMax / 8);
    k := 0;
    i := 0;
    for l := 300 to 500 do
    begin
      if BookArray[l] = 0 then continue;
      i := i + 1;
      if i <= BookPage * 8 then continue;
      Png := MapMonster(l);
      StateMap.Canvas.Draw(8, 40 + 48 * k, Png);
      CopyFight := NumFight;
      NumFight := l;
      GetTxt;
      StateMap.Canvas.TextOut(48,36 + 48 * k,'血:'+IntToStr(MonsterState[1]));
      StateMap.Canvas.TextOut(48,52 + 48 * k,'魔:'+IntToStr(MonsterState[2]));
      if MonsterState[18] = 0 then Att1 := MonsterState[3] - HeroState[4]
      else Att1 := MonsterState[5] - HeroState[6];
      if Att1 < 0 then Att1 := 0;
      if HeroState[18] = 0 then Att2 := HeroState[3] - MonsterState[4]
      else Att2 := HeroState[5] - MonsterState[6];
      if Att2 < 1 then Att2 := 1;
      s := MonsterState[1] * Att1 div Att2;
      StateMap.Canvas.TextOut(48,68 + 48 * k,'伤:'+IntToStr(s));
      if MonsterState[18] = 0 then
      begin
        StateMap.Canvas.TextOut(48 * 2,36 + 48 * k,'攻:'+IntToStr(MonsterState[3]));
        StateMap.Canvas.TextOut(48 * 3,36 + 48 * k,'防:'+IntToStr(MonsterState[4]));
      end
      else
      begin
        StateMap.Canvas.TextOut(48 * 2,36 + 48 * k,'攻:'+IntToStr(MonsterState[5]));
        StateMap.Canvas.TextOut(48 * 3,36 + 48 * k,'防:'+IntToStr(MonsterState[6]));
      end;
      StateMap.Canvas.TextOut(48 * 2,52 + 48 * k,'金:'+IntToStr(MonsterState[16]));
      StateMap.Canvas.TextOut(48 * 3,52 + 48 * k,'经:'+IntToStr(MonsterState[17]));
      NumFight := CopyFight;
      k := k + 1;
    end;
    Png.Free;
    Bmp.Free;
    exit;
  end;

  Bmp.Width:=32+2;
  Bmp.Height:=32+2;
  Bmp.Canvas.Brush.Color:=clyellow;
  Bmp.Canvas.Rectangle(-1,-1,35,35);
  StateMap.Canvas.Draw(32-1,40-1,Bmp);
  Png.LoadFromFile(getcurrentdir() + '\data\001.png');
  StateMap.Canvas.Draw(32,40,Png);
  Png.LoadFromFile(getcurrentdir() + '\data\101.png');
  StateMap.Canvas.Draw(32, 40, Png);

  StateMap.Canvas.Font.Color:=clwhite;
  StateMap.Canvas.Font.Name:='楷体';
  StateMap.Canvas.Font.Size:=12;
  StateMap.Canvas.Font.Style:=[fsBold];
  StateMap.canvas.Brush.style:=bsclear;
  str:=IntToStr(Floor);
  StateMap.Canvas.TextOut(32*2,8,'楼层 '+str);
  //StateMap.Canvas.Font.Color:=clblack;
  StateMap.Canvas.Font.Size:=8;
  StateMap.Canvas.TextOut(32*2+24,32,'等级:'+str);
  StateMap.Canvas.TextOut(32*2+24,32+16,'生命:'+IntToStr(HeroState[1]));
  StateMap.Canvas.TextOut(32*2+24,32*2,'魔法:'+IntToStr(HeroState[2]));
  StateMap.Canvas.TextOut(16,32*3,'攻击:'+IntToStr(HeroState[3]));
  StateMap.Canvas.TextOut(16,32*3+16,'防御:'+IntToStr(HeroState[4]));
  StateMap.Canvas.TextOut(32*2+24,32*3,'法攻:'+IntToStr(HeroState[5]));
  StateMap.Canvas.TextOut(32*2+24,32*3+16,'法防:'+IntToStr(HeroState[6]));
  StateMap.Canvas.TextOut(16,32*4+8,'命中:'+IntToStr(HeroState[13]));
  StateMap.Canvas.TextOut(16,32*4+24,'闪避:'+IntToStr(HeroState[14]));
  StateMap.Canvas.TextOut(32*2+24,32*4+8,'暴击:'+IntToStr(HeroState[12]));
  StateMap.Canvas.TextOut(32*2+24,32*4+24,'速度:'+IntToStr(HeroState[15]));
  if (WeaponItem[WeaponEquip[1]][5]) < 200 then StateMap.Canvas.TextOut(16,32*5+12,'攻技:'+SkillName(HeroState[7]))
  else StateMap.Canvas.TextOut(16,32*5+12,'通技:'+SkillName(HeroState[7]));
  if (WeaponItem[WeaponEquip[1]][6]) < 200 then StateMap.Canvas.TextOut(32*2+8,32*5+12,'攻技:'+SkillName(HeroState[8]))
  else StateMap.Canvas.TextOut(32*2+8,32*5+12,'通技:'+SkillName(HeroState[8]));
  if (WeaponItem[WeaponEquip[1]][7]) < 200 then StateMap.Canvas.TextOut(32*4,32*5+12,'攻技:'+SkillName(HeroState[9]))
  else StateMap.Canvas.TextOut(32*4,32*5+12,'通技:'+SkillName(HeroState[9]));
  //StateMap.Canvas.TextOut(32*2+8,32*5+12,'攻技2:'+SkillName(HeroState[8]));
  //StateMap.Canvas.TextOut(32*4,32*5+12,'攻技3:'+SkillName(HeroState[9]));
  if (WeaponItem[WeaponEquip[2]][5]) > 300 then StateMap.Canvas.TextOut(16,32*5+28,'防技:'+SkillName(HeroState[10]))
  else StateMap.Canvas.TextOut(16,32*5+28,'通技:'+SkillName(HeroState[10]));
  if (WeaponItem[WeaponEquip[2]][6]) > 300 then StateMap.Canvas.TextOut(32*2+8,32*5+28,'防技:'+SkillName(HeroState[11]))
  else StateMap.Canvas.TextOut(32*2+8,32*5+28,'通技:'+SkillName(HeroState[11]));
  //StateMap.Canvas.TextOut(16,32*5+28,'防技:'+SkillName(HeroState[10]));
  //StateMap.Canvas.TextOut(32*2+8,32*5+28,'通技:'+SkillName(HeroState[11]));
  //StateMap.Canvas.TextOut(32*4,32*4+8,'金钱:'+IntToStr(HeroState[16]));
  //StateMap.Canvas.TextOut(32*4,32*5+28,'经验:'+IntToStr(HeroState[17]));

  Png.LoadFromFile(getcurrentdir() + '\data\Menu\101.png');
  StateMap.Canvas.Draw(24,32*6+16,Png);
  StateMap.Canvas.TextOut(32+12,32*6+20,'= '+IntToStr(Item[101]));
  Png.LoadFromFile(getcurrentdir() + '\data\Menu\102.png');
  StateMap.Canvas.Draw(24,32*7+8,Png);
  StateMap.Canvas.TextOut(32+12,32*7+12,'= '+IntToStr(Item[102]));
  Png.LoadFromFile(getcurrentdir() + '\data\Menu\103.png');
  StateMap.Canvas.Draw(24,32*8,Png);
  StateMap.Canvas.TextOut(32+12,32*8+4,'= '+IntToStr(Item[103]));
  Png.LoadFromFile(getcurrentdir() + '\data\Menu\104.png');
  StateMap.Canvas.Draw(24,32*8+24,Png);
  StateMap.Canvas.TextOut(32+12,32*8+28,'= '+IntToStr(Item[104]));

  Png.LoadFromFile(getcurrentdir() + '\data\Menu\131.png');
  StateMap.Canvas.Draw(24,32*9+24,Png);
  StateMap.Canvas.TextOut(32+12,32*9+28,'= '+IntToStr(Item[131]));
  Png.LoadFromFile(getcurrentdir() + '\data\Menu\132.png');
  StateMap.Canvas.Draw(24,32*10+14,Png);
  StateMap.Canvas.TextOut(32+12,32*10+18,'= '+IntToStr(Item[132]));
  Png.LoadFromFile(getcurrentdir() + '\data\Menu\133.png');
  StateMap.Canvas.Draw(24,32*11+4,Png);
  StateMap.Canvas.TextOut(32+12,32*11+8,'= '+IntToStr(Item[133]));

  Png.LoadFromFile(getcurrentdir() + '\data\Menu\121.png');
  StateMap.Canvas.Draw(24,32*12,Png);
  StateMap.Canvas.TextOut(32+12,32*12+4,'= '+IntToStr(HeroState[16]));
  Png.LoadFromFile(getcurrentdir() + '\data\Menu\182.png');
  StateMap.Canvas.Draw(32*3+4,32*12,Png);
  StateMap.Canvas.TextOut(32*3+24,32*12+4,'= '+IntToStr(HeroState[17]));
  Png.LoadFromFile(getcurrentdir() + '\data\Menu\181.png');
  StateMap.Canvas.Draw(32*3+24,32*6+16,Png);

  Bmp.Width:=32+2;
  Bmp.Height:=32+2;
  Bmp.Canvas.Brush.Color:=clyellow;
  Bmp.Canvas.Rectangle(-1,-1,35,35);
  StateMap.Canvas.Draw(32*2+24-1,32*7+16-1,Bmp);
  StateMap.Canvas.Draw(32*4+8-1,32*7+16-1,Bmp);
  Png.LoadFromFile(getcurrentdir() + '\data\001.png');
  StateMap.Canvas.Draw(32*2+24,32*7+16,Png);
  StateMap.Canvas.Draw(32*4+8,32*7+16,Png);

  Png.LoadFromFile(getcurrentdir() + '\data\001.png');
  case WeaponItem[WeaponEquip[1]][1] of
    201: Png.LoadFromFile(getcurrentdir() + '\data\Item\201.png');
    202: Png.LoadFromFile(getcurrentdir() + '\data\Item\202.png');
    203: Png.LoadFromFile(getcurrentdir() + '\data\Item\203.png');
    204: Png.LoadFromFile(getcurrentdir() + '\data\Item\204.png');
    205: Png.LoadFromFile(getcurrentdir() + '\data\Item\205.png');
    221: Png.LoadFromFile(getcurrentdir() + '\data\Item\221.png');
    222: Png.LoadFromFile(getcurrentdir() + '\data\Item\222.png');
    223: Png.LoadFromFile(getcurrentdir() + '\data\Item\223.png');
    224: Png.LoadFromFile(getcurrentdir() + '\data\Item\224.png');
    225: Png.LoadFromFile(getcurrentdir() + '\data\Item\225.png');
  end;
  StateMap.Canvas.Draw(32*2+24,32*7+16,Png);

  Png.LoadFromFile(getcurrentdir() + '\data\001.png');
  case WeaponItem[WeaponEquip[2]][1] of
    211: Png.LoadFromFile(getcurrentdir() + '\data\Item\211.png');
    212: Png.LoadFromFile(getcurrentdir() + '\data\Item\212.png');
    213: Png.LoadFromFile(getcurrentdir() + '\data\Item\213.png');
    214: Png.LoadFromFile(getcurrentdir() + '\data\Item\214.png');
    215: Png.LoadFromFile(getcurrentdir() + '\data\Item\215.png');
    231: Png.LoadFromFile(getcurrentdir() + '\data\Item\231.png');
    232: Png.LoadFromFile(getcurrentdir() + '\data\Item\232.png');
    233: Png.LoadFromFile(getcurrentdir() + '\data\Item\233.png');
    234: Png.LoadFromFile(getcurrentdir() + '\data\Item\234.png');
    235: Png.LoadFromFile(getcurrentdir() + '\data\Item\235.png');
  end;
  StateMap.Canvas.Draw(32*4+8,32*7+16,Png);

  {if (Item[201]=1)Or(Item[202]=1)Or(Item[203]=1)Or(Item[204]=1)Or(Item[205]=1) then
  Png.LoadFromFile(getcurrentdir() + '\data\Menu\501.png');
  if (Item[221]=1)Or(Item[222]=1)Or(Item[223]=1)Or(Item[224]=1)Or(Item[225]=1) then
  Png.LoadFromFile(getcurrentdir() + '\data\Menu\503.png');
  StateMap.Canvas.Draw(32*3,32*9,Png);
  if (Item[211]=1)Or(Item[212]=1)Or(Item[213]=1)Or(Item[214]=1)Or(Item[215]=1) then
  Png.LoadFromFile(getcurrentdir() + '\data\Menu\502.png');
  StateMap.Canvas.Draw(32*4+16,32*9,Png);  } //宝石

  Png.Free;
  Bmp.Free;
end;

procedure Tr.Equip;
var
  Png:TPngImage;
  Bmp,BmpBack,FightBmp:TBitMap;
  i,j,k,hNum:Integer;
begin
  Png:=TPngImage.Create;
  Bmp:=TBitMap.Create;
  BmpBack:=TBitMap.Create;
  FightBmp:=TBitMap.Create;
  hNum := 32*32;
  FightBmp.Width:=32*Num;
  FightBmp.Height:=32*(Num-8);
  FightBmp.Canvas.Brush.Color:=clyellow;
  FightBmp.Canvas.Rectangle(-1,-1,32*Num+1,32*(Num-8)+1);
  Png.LoadFromFile(getcurrentdir() + '\data\001.png');
  for i := 0 to Num-1 do
    for j := 4 to Num-5 do
      Map.Canvas.Draw(32*i,32*j,Png);
  FightBmp.Canvas.CopyRect(Rect(2,2,32*Num-2,32*(Num-8)-2),Map.Canvas,Rect(0,32*4,32*Num,32*(Num-4)));
  Map.Canvas.Draw(0,32*4,FightBmp);
  Bmp.Width := 2 * 32;
  Bmp.Height := 2 * 32;
  BmpBack.Width := 2 * 32 + 4;
  BmpBack.Height := 2 * 32 + 4;
  for k := 1 to 4 do
  begin
    if pageNum = k then BmpBack.Canvas.Brush.Color:=clwhite
    else BmpBack.Canvas.Brush.Color:=clyellow;
    BmpBack.Canvas.Rectangle(-1,-1,73,73);
    for i := 0 to 1 do
      for j := 0 to 1 do
        BmpBack.Canvas.Draw(2+32*i,2+32*j,Png);
    Map.Canvas.Draw(32-2+32*3*(k-1),32*5-2,BmpBack);
    Png.LoadFromFile(getcurrentdir() + '\data\001.png');
    Map.Canvas.Draw(hNum,hNum,Png);
    case WeaponItem[4 * page + k][1] of
    201: Png.LoadFromFile(getcurrentdir() + '\data\Item\201.png');
    202: Png.LoadFromFile(getcurrentdir() + '\data\Item\202.png');
    203: Png.LoadFromFile(getcurrentdir() + '\data\Item\203.png');
    204: Png.LoadFromFile(getcurrentdir() + '\data\Item\204.png');
    205: Png.LoadFromFile(getcurrentdir() + '\data\Item\205.png');
    211: Png.LoadFromFile(getcurrentdir() + '\data\Item\211.png');
    212: Png.LoadFromFile(getcurrentdir() + '\data\Item\212.png');
    213: Png.LoadFromFile(getcurrentdir() + '\data\Item\213.png');
    214: Png.LoadFromFile(getcurrentdir() + '\data\Item\214.png');
    215: Png.LoadFromFile(getcurrentdir() + '\data\Item\215.png');
    221: Png.LoadFromFile(getcurrentdir() + '\data\Item\221.png');
    222: Png.LoadFromFile(getcurrentdir() + '\data\Item\222.png');
    223: Png.LoadFromFile(getcurrentdir() + '\data\Item\223.png');
    224: Png.LoadFromFile(getcurrentdir() + '\data\Item\224.png');
    225: Png.LoadFromFile(getcurrentdir() + '\data\Item\225.png');
    231: Png.LoadFromFile(getcurrentdir() + '\data\Item\231.png');
    232: Png.LoadFromFile(getcurrentdir() + '\data\Item\232.png');
    233: Png.LoadFromFile(getcurrentdir() + '\data\Item\233.png');
    234: Png.LoadFromFile(getcurrentdir() + '\data\Item\234.png');
    235: Png.LoadFromFile(getcurrentdir() + '\data\Item\235.png');
    end;
    Map.Canvas.Draw(hNum,hNum,Png);
    Bmp.Canvas.CopyRect(Rect(0,0,32*2,32*2),Map.Canvas,Rect(hNum,hNum,hNum+32,hNum+32));
    if (WeaponItem[4 * page + k][1] > 200)And(WeaponItem[4 * page + k][1] < 250) then
    begin
      Bmp.Canvas.Font.Color:=clwhite;
      Bmp.Canvas.Font.Name:='楷体';
      Bmp.Canvas.Font.Style:=[fsBold];
      Bmp.Canvas.Brush.style:=bsClear;
      Bmp.Canvas.Font.Size:=8;
      Bmp.Canvas.TextOut(4, 4, IntToStr(WeaponItem[4 * page + k][4]));
    end;
    Map.Canvas.Draw(32+32*3*(k-1),32*5,Bmp);
    //BackMap
    //1.排序 2.属性
    //1.类型 2.名称 3.星级 4.攻击/防御 5.宝石1 6.宝石2 7.宝石3
    //Show WeaponItem[m];
    for i := 1 to WeaponItem[4 * page + k][3] do
    begin
      Png.LoadFromFile(getcurrentdir() + '\data\Menu\circle.png');
      Map.Canvas.Draw(32+32*3*(k-1)+22*(i-1),32*5-24,Png);
      if WeaponItem[4 * page + k][4 + i] <> 0 then
      begin
        //Png.LoadFromFile(getcurrentdir() + '\data\Menu\501.png');
        case WeaponItem[4 * page + k][4 + i] of
          100..149: Png.LoadFromFile(getcurrentdir() + '\data\Menu\501.png');
          150..199: Png.LoadFromFile(getcurrentdir() + '\data\Menu\502.png');
          200..299: Png.LoadFromFile(getcurrentdir() + '\data\Menu\505.png');
          300..349: Png.LoadFromFile(getcurrentdir() + '\data\Menu\504.png');
          350..399: Png.LoadFromFile(getcurrentdir() + '\data\Menu\503.png');
        end;
        Map.Canvas.Draw(32+32*3*(k-1)+22*(i-1)+2,32*5-24+2,Png);
      end;
    end;
  end;
  BmpBack.Width := 32 + 2;
  BmpBack.Height := 32 + 2;
  for k := 1 to 7 do
  begin
    if GemNum = k then BmpBack.Canvas.Brush.Color:=clwhite
    else BmpBack.Canvas.Brush.Color:=clyellow;
    BmpBack.Canvas.Rectangle(-1,-1,37,37);
    Png.LoadFromFile(getcurrentdir() + '\data\001.png');
    BmpBack.Canvas.Draw(1,1,Png);
    case GemItem[7 * GemPage + k] of
      100..149: Png.LoadFromFile(getcurrentdir() + '\data\Menu\501.png');
      150..199: Png.LoadFromFile(getcurrentdir() + '\data\Menu\502.png');
      200..299: Png.LoadFromFile(getcurrentdir() + '\data\Menu\505.png');
      300..349: Png.LoadFromFile(getcurrentdir() + '\data\Menu\504.png');
      350..399: Png.LoadFromFile(getcurrentdir() + '\data\Menu\503.png');
    end;
    if GemItem[7 * GemPage + k] > 0 then BmpBack.Canvas.Draw(9,9,Png);
    Map.Canvas.Draw(48-1+16*3*(k-1),32*7+16-1,BmpBack);
  end;
  if Not(EquipOrGem) then
  begin
    Bmp.Width := 2 * 32;
    Bmp.Height := 2 * 32;
    BmpBack.Width := 2 * 32 + 4;
    BmpBack.Height := 2 * 32 + 4;
    BmpBack.Canvas.Brush.Color:=clwhite;
    BmpBack.Canvas.Rectangle(-1,-1,69,69);
    Bmp := GemPicture(GemItem[7 * GemPage + GemNum]);

    BmpBack.Canvas.Font.Color:=clyellow;
    BmpBack.Canvas.Font.Name:='楷体';
    BmpBack.Canvas.Font.Style:=[fsBold];
    BmpBack.Canvas.Brush.style:=bsClear;
    BmpBack.Canvas.Font.Size:=8;
    BmpBack.Canvas.Draw(2,2,Bmp);
    BmpBack.Canvas.TextOut(21, 6, SkillName(GemItem[7 * GemPage + GemNum]));
    Map.Canvas.Draw(32-2+16*3*(GemNum-1),32*7-8-2,BmpBack);
  end;

  if EquipChoose then
  begin
    Bmp.Width := 32;
    Bmp.Height := 16;
    BmpBack.Width := 32 + 1;
    BmpBack.Height := 16 * 5 + 1;
    FightBmp.Width := 32 + 1;
    FightBmp.Height := 16 * 5 + 1;

    BmpBack.Canvas.Pen.Color:=clred;
    BmpBack.Canvas.Brush.Color := clYellow;
    //BmpBack.Canvas.Brush.Color := clWindow;
    //BmpBack.Canvas.Brush.Style := bsSolid;
    BmpBack.Canvas.Rectangle(0,0,33,81);
    BmpBack.Canvas.Rectangle(0,16,33,65);
    BmpBack.Canvas.Rectangle(0,32,33,49);
    BmpBack.Canvas.Pen.Color:=clblue;
    BmpBack.Canvas.Rectangle(0,16*(EquipNum-1),33,16*EquipNum+1);

    BmpBack.Canvas.Font.Name:='楷体';
    BmpBack.Canvas.Font.Style:=[fsBold];
    BmpBack.canvas.Brush.style:=bsClear;
    BmpBack.Canvas.Font.Size:=8;

    if EquipNum <> 1 then BmpBack.Canvas.Font.Color:=clred
    else BmpBack.Canvas.Font.Color:=clblue;
    BmpBack.Canvas.TextOut(4,3,'查看');
    if EquipNum <> 2 then BmpBack.Canvas.Font.Color:=clred
    else BmpBack.Canvas.Font.Color:=clblue;
    if (WeaponEquip[1] = 4 * page + pageNum)Or(WeaponEquip[2] = 4 * page + pageNum) then
    BmpBack.Canvas.TextOut(4,16+3,'解除')
    else BmpBack.Canvas.TextOut(4,16+3,'装备');
    if EquipNum <> 3 then BmpBack.Canvas.Font.Color:=clred
    else BmpBack.Canvas.Font.Color:=clblue;
    BmpBack.Canvas.TextOut(4,16*2+3,'镶嵌');
    if EquipNum <> 4 then BmpBack.Canvas.Font.Color:=clred
    else BmpBack.Canvas.Font.Color:=clblue;
    BmpBack.Canvas.TextOut(4,16*3+3,'丢弃');
    if EquipNum <> 5 then BmpBack.Canvas.Font.Color:=clred
    else BmpBack.Canvas.Font.Color:=clblue;
    BmpBack.Canvas.TextOut(4,16*4+3,'取消');
    Map.Canvas.Draw(32*2+8-1+32*3*(pageNum-1),32*5+8-1,BmpBack);
  end;

  if GemChoose then
  begin
    Bmp.Width := 32;
    Bmp.Height := 16;
    BmpBack.Width := 32 + 1;
    BmpBack.Height := 16 * 3 + 1;
    FightBmp.Width := 32 + 1;
    FightBmp.Height := 16 * 3 + 1;

    BmpBack.Canvas.Pen.Color:=clred;
    BmpBack.Canvas.Brush.Color := clYellow;
    //BmpBack.Canvas.Brush.Style := bsSolid;
    BmpBack.Canvas.Rectangle(0,0,33,49);
    BmpBack.Canvas.Rectangle(0,16,33,33);
    BmpBack.Canvas.Pen.Color:=clblue;
    BmpBack.Canvas.Rectangle(0,16*(GemNumber-1),33,16*GemNumber+1);

    BmpBack.Canvas.Font.Name:='楷体';
    BmpBack.Canvas.Font.Style:=[fsBold];
    BmpBack.canvas.Brush.style:=bsclear;
    BmpBack.Canvas.Font.Size:=8;

    if GemNumber <> 1 then BmpBack.Canvas.Font.Color:=clred
    else BmpBack.Canvas.Font.Color:=clblue;
    BmpBack.Canvas.TextOut(4,3,'查看');
    if GemNumber <> 2 then BmpBack.Canvas.Font.Color:=clred
    else BmpBack.Canvas.Font.Color:=clblue;
    BmpBack.Canvas.TextOut(4,16+3,'丢弃');
    if GemNumber <> 3 then BmpBack.Canvas.Font.Color:=clred
    else BmpBack.Canvas.Font.Color:=clblue;
    BmpBack.Canvas.TextOut(4,16*2+3,'取消');
    Map.Canvas.Draw(32*2+8-1+16*3*(GemNum-1),32*7+4-1,BmpBack);
  end;
  Png.Free;
  Bmp.Free;
  BmpBack.Free;
  FightBmp.Free;
end;

function Check(i,n:Integer):Boolean;
begin
  if (FightArray[n][7]=i)Or(FightArray[n][8]=i)Or(FightArray[n][9]=i)Or
  (FightArray[n][10]=i)Or(FightArray[n][11]=i) then Result:=True else Result:=False;
  {case i of
  100..199: if (FightArray[n][7]=i)Or(FightArray[n][8]=i)Or(FightArray[n][9]=i) then Result:=True else Result:=False;
  200..299: if FightArray[n][11]=i then Result:=True else Result:=False;
  300..399: if FightArray[n][10]=i then Result:=True else Result:=False;
  end;}
end;

procedure Tr.GetTxt;
var
  pFile: TextFile;
  pStr: String;
  i, k: Integer;
begin
  AssignFile(pFile,getcurrentdir() + '\data\Monster.csv');
  Reset(pFile);
  Readln(pFile, pStr);
  while Not(EOF(pFile)) do
  begin
    Readln(pFile, pStr);
    if StrToInt(LeftStr(pStr, 3)) = NumFight then
    begin
      for i := 1 to 18 do MonsterRead[i] := StrToInt(MidStr(pStr, 4 * i + 1, 3));
    end;
  end;
  if MonsterRead[18] = 100 then MonsterState[18] := 0
  else MonsterState[18] := 1;
  if MonsterState[18] = 0 then
  begin
    MonsterBase[1] := (MonsterBase[3] + MonsterBase[4]) * 1;
    MonsterBase[2] := 0;
  end
  else
  begin
    MonsterBase[1] := (MonsterBase[5] + MonsterBase[6]) * 2;
    MonsterBase[2] := MonsterBase[1] * 3 div 2;
  end;
  MonsterState[1] := MonsterRead[1] * MonsterBase[1] div 100;
  MonsterState[2] := MonsterRead[2] * MonsterBase[2] div 100;

  MonsterState[3] := MonsterRead[3] * MonsterBase[3] div 100;
  MonsterState[4] := MonsterRead[4] * MonsterBase[4] div 100;
  MonsterState[5] := MonsterRead[5] * MonsterBase[5] div 100;
  MonsterState[6] := MonsterRead[6] * MonsterBase[6] div 100;

  for i := 7 to 11 do
  begin
    if MonsterRead[i] = 100 then  MonsterState[i] := 0
    else MonsterState[i] := MonsterRead[i];
  end;

  MonsterState[12] := MonsterRead[12] - 100;
  MonsterState[13] := MonsterRead[13] - 100;
  MonsterState[14] := MonsterRead[14] - 100;
  MonsterState[15] := MonsterRead[15] - 100;

  MonsterState[16] := MonsterRead[16] * MonsterBase[16] div 100;
  MonsterState[17] := MonsterRead[17] * MonsterBase[17] div 100;
end;

procedure GetRecord;
var
  i,j:Integer;
begin
  for i := 1 to 18 do
  begin
    FightArray[0][i]:=MonsterState[i];
    FightArray[1][i]:=HeroState[i];
  end;
  if Check(201,0) then FightArray[0][3]:=FightArray[0][3]+Trunc(MonsterState[3]/5);
  if (Check(208,0))Or(Check(208,1)) then FightArray[0][3]:=FightArray[0][3]+Trunc(MonsterState[3]/3);
  if Check(304,0) then FightArray[0][3]:=FightArray[0][3]-Trunc(MonsterState[3]/5);
  if (Check(203,1))And(MonsterState[3]<HeroState[3]) then
    FightArray[0][3]:=FightArray[0][3]-Trunc(MonsterState[3]/5);
  if Check(301,0) then FightArray[0][4]:=FightArray[0][4]+Trunc(MonsterState[4]/5);
  if Check(305,0) then FightArray[0][4]:=FightArray[0][4]+Trunc(HeroState[3]/5);
  if Check(354,0) then FightArray[0][4]:=FightArray[0][4]+Trunc(MonsterState[6]/2);
  if (Check(208,0))Or(Check(208,1)) then FightArray[0][4]:=FightArray[0][4]-Trunc(MonsterState[4]/3);
  if Check(151,0) then FightArray[0][5]:=FightArray[0][5]+Trunc(MonsterState[5]/5);
  if (Check(208,0))Or(Check(208,1)) then FightArray[0][5]:=FightArray[0][5]+Trunc(MonsterState[5]/3);
  if Check(354,0) then FightArray[0][6]:=FightArray[0][6]+Trunc(MonsterState[4]/2);
  if (Check(208,0))Or(Check(208,1)) then FightArray[0][6]:=FightArray[0][6]-Trunc(MonsterState[6]/3);
  if Check(202,0) then FightArray[0][12]:=FightArray[0][12]+10;
  if Check(205,0) then FightArray[0][14]:=FightArray[0][14]+10;
  if Check(206,0) then FightArray[0][14]:=FightArray[0][14]+30;
  if Check(205,0) then FightArray[0][15]:=FightArray[0][15]+Trunc(MonsterState[15]/5);

  if Check(201,1) then FightArray[1][3]:=FightArray[1][3]+Trunc(HeroState[3]/5);
  if (Check(208,0))Or(Check(208,1)) then FightArray[1][3]:=FightArray[1][3]+Trunc(HeroState[3]/3);
  if Check(304,1) then FightArray[1][3]:=FightArray[1][3]-Trunc(HeroState[3]/5);
  if (Check(203,0))And(MonsterState[3]>HeroState[3]) then
    FightArray[1][3]:=FightArray[1][3]-Trunc(HeroState[3]/5);
  if Check(301,1) then FightArray[1][4]:=FightArray[1][4]+Trunc(HeroState[4]/5);
  if Check(305,1) then FightArray[1][4]:=FightArray[1][4]+Trunc(MonsterState[3]/5);
  if Check(354,0) then FightArray[1][4]:=FightArray[1][4]+Trunc(HeroState[6]/2);
  if (Check(208,0))Or(Check(208,1)) then FightArray[1][4]:=FightArray[1][4]-Trunc(HeroState[4]/3);
  if Check(151,1) then FightArray[1][5]:=FightArray[1][5]+Trunc(HeroState[5]/5);
  if (Check(208,0))Or(Check(208,1)) then FightArray[1][5]:=FightArray[1][5]+Trunc(HeroState[5]/3);
  if Check(354,0) then FightArray[1][6]:=FightArray[1][6]+Trunc(HeroState[4]/2);
  if (Check(208,0))Or(Check(208,1)) then FightArray[1][6]:=FightArray[1][6]-Trunc(HeroState[6]/3);
  if Check(202,1) then FightArray[1][12]:=FightArray[1][12]+10;
  if Check(205,1) then FightArray[1][14]:=FightArray[1][14]+10;
  if Check(206,1) then FightArray[1][14]:=FightArray[1][14]+30;
  if Check(205,1) then FightArray[1][15]:=FightArray[1][15]+Trunc(HeroState[15]/5);

  for i := 0 to 1 do
    for j := 1 to 17 do
      FightNum[i][j]:=FightArray[i][j];
end;

function Tr.GemPicture(n:Integer):TBitMap;
var
  Png:TPngImage;
  Bmp:TBitMap;
  i,j,hNum:Integer;
begin
  Png:=TPngImage.Create;
  Bmp:=TBitMap.Create;
  hNum := 32 * 32;
  Bmp.Width := 64;
  Bmp.Height := 64;
  Png.LoadFromFile(getcurrentdir() + '\data\001.png');
  Bmp.Canvas.CopyRect(Rect(0,0,64,64),Png.Canvas,Rect(0,0,32,32));
  Map.Canvas.Draw(hNum,hNum,Bmp);
  Png.LoadFromFile(getcurrentdir() + '\data\Menu\800.png');
  case n of
  101:
  begin
    i := 1;
    j := 1;
  end;
  102:
  begin
    i := 1;
    j := 4;
  end;
  103:
  begin
    i := 2;
    j := 2;
  end;
  104:
  begin
    i := 3;
    j := 5;
  end;
  105:
  begin
    i := 3;
    j := 3;
  end;
  106:
  begin
    i := 3;
    j := 2;
  end;
  107:
  begin
    i := 0;
    j := 0;
  end;
  108:
  begin
    i := 1;
    j := 5;
  end;
  109:
  begin
    i := 3;
    j := 3;
  end;
  110:
  begin
    i := 0;
    j := 0;
  end;
  111:
  begin
    i := 1;
    j := 3;
  end;
  112:
  begin
    i := 3;
    j := 4;
  end;
  113:
  begin
    i := 0;
    j := 0;
  end;
  151:
  begin
    i := 2;
    j := 4;
  end;
  152:
  begin
    i := 3;
    j := 3;
  end;
  153:
  begin
    i := 3;
    j := 4;
  end;
  154:
  begin
    i := 3;
    j := 5;
  end;
  155:
  begin
    i := 3;
    j := 1;
  end;
  156:
  begin
    i := 4;
    j := 1;
  end;
  157:
  begin
    i := 2;
    j := 5;
  end;
  158:
  begin
    i := 1;
    j := 1;
  end;
  159:
  begin
    i := 0;
    j := 0;
  end;
  201:
  begin
    i := 1;
    j := 1;
  end;
  202:
  begin
    i := 1;
    j := 4;
  end;
  203:
  begin
    i := 1;
    j := 5;
  end;
  204:
  begin
    i := 2;
    j := 2;
  end;
  205:
  begin
    i := 2;
    j := 3;
  end;
  206:
  begin
    i := 2;
    j := 5;
  end;
  207:
  begin
    i := 0;
    j := 0;
  end;
  208:
  begin
    i := 3;
    j := 2;
  end;
  209:
  begin
    i := 0;
    j := 0;
  end;
  210:
  begin
    i := 0;
    j := 0;
  end;
  301:
  begin
    i := 3;
    j := 2;
  end;
  302:
  begin
    i := 2;
    j := 3;
  end;
  303:
  begin
    i := 4;
    j := 3;
  end;
  304:
  begin
    i := 2;
    j := 1;
  end;
  305:
  begin
    i := 3;
    j := 1;
  end;
  306:
  begin
    i := 2;
    j := 5;
  end;
  351:
  begin
    i := 2;
    j := 3;
  end;
  352:
  begin
    i := 1;
    j := 3;
  end;
  353:
  begin
    i := 4;
    j := 2;
  end;
  354:
  begin
    i := 1;
    j := 2;
  end;
  end;
  Map.Canvas.Draw(hNum - 64 * (j - 1),hNum - 64 * (i - 1),Png);
  Bmp.Canvas.CopyRect(Rect(0, 0, 64, 64), Map.Canvas, Rect(hNum, hNum, hNum + 64, hNum + 64));
  Result:=Bmp;
  //Png.Free;
  //Bmp.Free;
end;

function SkillName(n:Integer):String;
var
  str:String;
begin
  case n of
  101: str:='吸血';
  102: str:='必杀';
	103: str:='连击';
	104: str:='破甲';
	105: str:='精准';
	106: str:='强击';
	107: str:='重击';
	108: str:='衰竭';
	109: str:='损毁';
	110: str:='诅咒';
	111: str:='疯狂';
	112: str:='先攻';
	113: str:='反击';
	151: str:='巫术';
	152: str:='魔爆';
	153: str:='灵噬';
	154: str:='湮灭';
	155: str:='灵魄';
	156: str:='震荡';
	157: str:='破碎';
	158: str:='能量';
	159: str:='复仇';
	201: str:='英雄';
	202: str:='霸王';
	203: str:='压制';
	204: str:='活络';
	205: str:='灵动';
	206: str:='迅捷';
	207: str:='迟滞';
	208: str:='天变';
	209: str:='背水';
	210: str:='不灭';
	301: str:='守备';
	302: str:='格挡';
	303: str:='强守';
	304: str:='铁壁';
	305: str:='坚韧';
	306: str:='反震';
	351: str:='魔甲';
	352: str:='灵护';
	353: str:='结界';
	354: str:='神御';
  else str:='';
  end;
  Result:=str;
end;

function SkillIntroduce(n:Integer):String;
var
  str:String;
begin
  case n of
  101: str := '攻击时吸取造成伤害值一定比例的生命';
  102: str := '攻击时一定几率造成双倍伤害';
  103: str := '攻击时一定几率再次攻击';
  104: str := '攻击忽视一定的防御';
  105: str := '攻击必中';
  106: str := '每次攻击都会提高一定攻击，直到战斗结束';
  107: str := '攻击一定几率使得对方下回合无法行动';
  108: str := '攻击额外造成当前生命一定比例的伤害';
  109: str := '攻击额外使对方损失一定魔法值';
  110: str := '被攻击目标下回合无法恢复生命';
  111: str := '第一回合攻击两次';
  112: str := '率先发动攻击';
  113: str := '受到物理攻击一定几率反击对手';
  151: str := '提高魔法攻击';
  152: str := '每次魔法攻击都会提高自身一定的魔法攻击，持续到战斗结束';
  153: str := '每次魔法攻击都会吸取对方一定的魔法防御附加给自己，持续到战斗结束';
  154: str := '魔法攻击一定几率给对方造成大量伤害';
  155: str := '每次魔法攻击都会回复自身一定魔法值';
  156: str := '魔法攻击造成大幅波动';
  157: str := '大幅提高魔法伤害，但自身造成的魔法伤害以一定比例反作用于自己';
  158: str := '每数回合提高一定的魔法攻击和魔法防御';
  159: str := '魔法攻击附加上回合自身受到的一定比例的伤害';
  201: str := '提高自身一定攻击防御';{，且无视对方特效}
  202: str := '提高一定的必杀率，攻击未必杀提高一定几率必杀率，持续到战斗结束';
  203: str := '对方攻击小于自身则降低对方一定攻击';
  204: str := '每回合回复一定的生命和魔法';
  205: str := '提高一定闪避和速度';
  206: str := '大幅提高自身闪避';
  207: str := '降低对方必杀率闪避率和速度';
  208: str := '提高双方的攻击和魔法攻击，降低双方的防御和魔法防御';
  209: str := '提高本次战斗损失生命一定比例的攻击和防御';
  210: str := '自身濒死时获得一次额外回合，额外回合若杀死敌人则回复少量生命';
  301: str := '增加一定的防御力';
  302: str := '一定几率抵挡本次物理伤害和附加伤害';
  303: str := '无视附加伤害，受到的魔法伤害加倍';
  304: str := '大幅降低自身受到的物理伤害，但自身攻击力也会降低';
  305: str := '战斗开始时，提高对方攻击力一定比例的防御';
  306: str := '将受到物理伤害的部分反馈给对方';
  351: str := '用魔法抵挡一部分的伤害';
  352: str := '降低受到的魔法伤害和物理伤害，但附加伤害会提高';
  353: str := '每数回合完全躲避一次物理伤害和附加伤害';
  354: str := '自身魔法防御值附加一定比例到物理防御，自身物理防御值附加一定比例到魔法防御';
  else str := '';
  end;
  Result:=str;
end;


procedure Tr.StartFight;
var
  Png:TPngImage;
  FightBmp:TBitMap;
  i,j:Integer;
begin
  Png:=TPngImage.Create;
  FightBmp:=TBitMap.Create;
  Png.LoadFromFile(getcurrentdir() + '\data\001.png');
  FightBmp.Width:=32*Num;
  FightBmp.Height:=32*(Num-8);
  FightBmp.Canvas.Brush.Color:=clyellow;
  FightBmp.Canvas.Rectangle(0-1,0-1,32*Num+1,32*(Num-8)+1);
  for i := 0 to Num-1 do
    for j := 4 to Num-5 do
      Map.Canvas.Draw(32*i,32*j,Png);
  FightBmp.Canvas.CopyRect(Rect(2,2,32*Num-2,32*(Num-8)-2),Map.Canvas,Rect(0,32*4,32*Num,32*(Num-4)));
  Map.Canvas.Draw(0,32*4,FightBmp);
  FightBmp.Width:=32+4;
  FightBmp.Height:=32+4;
  FightBmp.Canvas.Brush.Color:=clyellow;
  FightBmp.Canvas.Rectangle(-1,-1,37,37);
  Map.Canvas.Draw(32-2,32*4+24-2,FightBmp);
  Map.Canvas.Draw(32,32*4+24,Png);
  Map.Canvas.Draw(32*(Num-2)-2,32*4+24-2,FightBmp);
  Map.Canvas.Draw(32*(Num-2),32*4+24,Png);
  Map.Canvas.Font.Color:=clwhite;
  Map.Canvas.Font.Name:='楷体';
  Map.Canvas.Font.Style:=[fsBold];
  Map.canvas.Brush.style:=bsclear;
  Map.Canvas.Font.Size:=8;
  Png.Free;
  FightBmp.Free;
end;

procedure Tr.FightPrint;
var
  str:String;
begin
  Map.Canvas.TextOut(32*2+24,32*4+24,'生命:'+IntToStr(FightArray[0][1]));
  Map.Canvas.TextOut(32*2+24,32*5+8,'魔法:'+IntToStr(FightArray[0][2]));
  Map.Canvas.TextOut(16,32*6,'攻击:'+IntToStr(FightArray[0][3]));
  Map.Canvas.TextOut(16,32*6+16,'防御:'+IntToStr(FightArray[0][4]));
  Map.Canvas.TextOut(32*2+8,32*6,'法攻:'+IntToStr(FightArray[0][5]));
  Map.Canvas.TextOut(32*2+8,32*6+16,'法防:'+IntToStr(FightArray[0][6]));
  Map.Canvas.TextOut(16,32*7+8,'命中:'+IntToStr(FightArray[0][13]));
  Map.Canvas.TextOut(16,32*7+24,'闪避:'+IntToStr(FightArray[0][14]));
  Map.Canvas.TextOut(32*2+8,32*7+8,'暴击:'+IntToStr(FightArray[0][12]));
  Map.Canvas.TextOut(32*2+8,32*7+24,'速度:'+IntToStr(FightArray[0][15]));
  Map.Canvas.TextOut(32*4,32*6,'攻技1:'+SkillName(FightArray[0][7]));
  Map.Canvas.TextOut(32*4,32*6+16,'攻技2:'+SkillName(FightArray[0][8]));
  Map.Canvas.TextOut(32*4,32*7,'攻技3:'+SkillName(FightArray[0][9]));
  Map.Canvas.TextOut(32*4,32*7+16,'防技:'+SkillName(FightArray[0][10]));
  Map.Canvas.TextOut(32*4,32*8,'通技:'+SkillName(FightArray[0][11]));
  Map.Canvas.TextOut(16,32*8+12,'金钱:'+IntToStr(FightArray[0][16]));
  Map.Canvas.TextOut(32*2+8,32*8+12,'经验:'+IntToStr(FightArray[0][17]));
  str:=IntToStr(FightArray[1][1]);
  Map.Canvas.TextOut(32*(Num-4)+8-7*Length(str),32*4+24,str+':生命');
  str:=IntToStr(FightArray[1][2]);
  Map.Canvas.TextOut(32*(Num-4)+8-7*Length(str),32*5+8,str+':魔法');
  str:=IntToStr(FightArray[1][3]);
  Map.Canvas.TextOut(32*(Num-2)+16-7*Length(str),32*6,str+':攻击');
  str:=IntToStr(FightArray[1][4]);
  Map.Canvas.TextOut(32*(Num-2)+16-7*Length(str),32*6+16,str+':防御');
  str:=IntToStr(FightArray[1][5]);
  Map.Canvas.TextOut(32*(Num-4)+24-7*Length(str),32*6,str+':法攻');
  str:=IntToStr(FightArray[1][6]);
  Map.Canvas.TextOut(32*(Num-4)+24-7*Length(str),32*6+16,str+':法防');
  str:=IntToStr(FightArray[1][13]);
  Map.Canvas.TextOut(32*(Num-2)+16-7*Length(str),32*7+8,str+':命中');
  str:=IntToStr(FightArray[1][14]);
  Map.Canvas.TextOut(32*(Num-2)+16-7*Length(str),32*7+24,str+':闪避');
  str:=IntToStr(FightArray[1][12]);
  Map.Canvas.TextOut(32*(Num-4)+24-7*Length(str),32*7+8,str+':暴击');
  str:=IntToStr(FightArray[1][15]);
  Map.Canvas.TextOut(32*(Num-4)+24-7*Length(str),32*7+24,str+':速度');
  str:=SkillName(FightArray[1][7]);
  str:=SkillName(FightArray[1][7]);
  Map.Canvas.TextOut(32*(Num-6)+24-13*Length(str),32*6,str+':1攻技');
  str:=SkillName(FightArray[1][8]);
  Map.Canvas.TextOut(32*(Num-6)+24-13*Length(str),32*6+16,str+':2攻技');
  str:=SkillName(FightArray[1][9]);
  Map.Canvas.TextOut(32*(Num-6)+24-13*Length(str),32*7,str+':3攻技');
  str:=SkillName(FightArray[1][10]);
  Map.Canvas.TextOut(32*(Num-6)+24-13*Length(str),32*7+16,str+':防技');
  str:=SkillName(FightArray[1][11]);
  Map.Canvas.TextOut(32*(Num-6)+24-13*Length(str),32*8,str+':通技');
  str:=IntToStr(FightArray[1][16]);
  Map.Canvas.TextOut(32*(Num-2)+16-7*Length(str),32*8+12,str+':金钱');
  str:=IntToStr(FightArray[1][17]);
  Map.Canvas.TextOut(32*(Num-4)+24-7*Length(str),32*8+12,str+':经验');
end;

procedure Tr.TimerTimer(Sender: TObject);
var
  i,j:Integer;
  Png:TPngImage;
begin
  if TimeNum = 1 then
  begin
    TimeNum := TimeNum + 1;
    Png:=TPngImage.Create;
    Time:=(Time mod 4)+1;
    for i := 1 to Num do
      for j := 1 to Num do
      begin
        if (Allow)And(j>4)And(j-1<Num-4) then continue;
        if (MapArray[i,j]>300)And(MapArray[i,j]<500) then
        MonsterMove(32*(i-1),32*(j-1),MapArray[i,j],Time);
      end;
    if (Allow)And(FightAllow) then
    begin
      MonsterMove(32,32*4+24,NumFight,Time);
      Png.LoadFromFile(getcurrentdir() + '\data\101.png');
      Map.Canvas.Draw(32*(Num-2),32*4+24,Png);
    end;
    Png.Free;
  end
  else
  begin
    TimeNum := TimeNum + 1;
    if TimeNum > 5 then TimeNum := 1;
  end;
  if TimeAllow then
  begin
    Map.Canvas.Draw(32*(Num-2)-16,32*4+8,BmpLifeBack1);
    Map.Canvas.Draw(16,32*4+8,BmpLifeBack2);
    LifeFlash;
    LifeTime := LifeTime mod 6 + 1;
    if LifeTime = 1 then
    begin
      TimeAllow := False;
      Map.Canvas.Draw(32*(Num-2)-16,32*4+8,BmpLifeBack1);
      Map.Canvas.Draw(16,32*4+8,BmpLifeBack2);
    end;
  end;
end;

function Magic(n:Integer):Boolean;
begin
  if FightArray[n][18]=0 then Result:=False else Result:=True;
end;

procedure Tr.LifeFlash;
var
  Bmp:TBitMap;
  r1,r2:TRect;
  len:Integer;
begin
  Bmp:=TBitMap.Create;
  Bmp.Width:=64;
  Bmp.Height:=64;
  Bmp.Canvas.Font.Name := '黑体';
  Bmp.Canvas.Font.Style := [fsBold];
  Bmp.Canvas.Brush.style:=bsclear;
  Bmp.Canvas.Font.Size := 8 + LifeTime div 2;

  if HitChance then r1:=Rect(32*(Num-2)-16,32*4+8,32*(Num-2)+48,32*4+72)
  else r1:=Rect(16,32*4+8,32*2+16,32*6+8);
  if Not(HitChance) then LifeNumber1 := LifeBack[0] - FightArray[0][1]
  else LifeNumber1 := LifeBack[1] - FightArray[1][1];
  if LifeNumber1 >= 0 then LifeLost := True
  else
  begin
    LifeLost := False;
    LifeNumber1 := -LifeNumber1;
  end;
  if LifeLost then Bmp.Canvas.Font.Color := clred
  else Bmp.Canvas.Font.Color := clgreen;
  Bmp.Canvas.CopyRect(Rect(0,0,64,64),Map.Canvas,r1);
  case AttackChoose of
    5: Bmp.Canvas.TextOut(18, 25, 'Miss');
    else
    begin
      len := 33 - 4 * Length(IntToStr(LifeNumber1));
      Bmp.Canvas.TextOut(len, 25, IntToStr(LifeNumber1));
    end;
  end;
  if HitChance then Map.Canvas.Draw(32*(Num-2)-16,32*4+8,Bmp)
  else Map.Canvas.Draw(16,32*4+8,Bmp);

  if Not(HitChance) then r2:=Rect(32*(Num-2)-16,32*4+8,32*(Num-2)+48,32*4+72)
  else r2:=Rect(16,32*4+8,32*2+16,32*6+8);
  LifeNumber2 := 0;
  if HitChance then LifeNumber2 := LifeBack[0] - FightArray[0][1]
  else LifeNumber2 := LifeBack[1] - FightArray[1][1];
  if LifeNumber2 > 0 then LifeLost := True
  else if lifeNumber2 < 0 then
  begin
    LifeLost := False;
    LifeNumber2 := -LifeNumber2;
  end;
  if LifeLost then Bmp.Canvas.Font.Color := clred
  else Bmp.Canvas.Font.Color := clgreen;
  if LifeNumber2 <> 0 then
  begin
    Bmp.Canvas.CopyRect(Rect(0,0,64,64),Map.Canvas,r2);
    len := 33 - 4 * Length(IntToStr(LifeNumber2));
    Bmp.Canvas.TextOut(len, 25, IntToStr(LifeNumber2));
    if Not(HitChance) then Map.Canvas.Draw(32*(Num-2)-16,32*4+8,Bmp)
    else Map.Canvas.Draw(16,32*4+8,Bmp);
  end;

  Bmp.Free;
end;

procedure Tr.AttackFlash(n:Integer);
var
  Png:TPngImage;
  Bmp,BmpCopy:TBitMap;
  r:TRect;
  k,p,q,hNum:Integer;
begin
  Png:=TPngImage.Create;
  Bmp:=TBitMap.Create;
  BmpCopy:=TBitMap.Create;
  Bmp.Width:=64;
  Bmp.Height:=64;
  BmpCopy.Width:=64;
  BmpCopy.Height:=64;
  begin
    //MapView.Lines.Add('Attack!');
    Png.LoadFromFile(getcurrentdir() + '\data\Magic\103.png');
    p:=1;
    q:=5;
  end;
  case n of
  1:
  begin
    //MapView.Lines.Add('Attack!');
    Png.LoadFromFile(getcurrentdir() + '\data\Magic\103.png');
    p:=1;
    q:=5;
  end;
  2:
  begin
    //MapView.Lines.Add('Double Attack!');
    Png.LoadFromFile(getcurrentdir() + '\data\Magic\102.png');
    p:=1;
    q:=5;
  end;
  3:
  begin
    //MapView.Lines.Add('Magic');
    Png.LoadFromFile(getcurrentdir() + '\data\Magic\104.png');
    p:=0;
    q:=5;
  end;
  4:
  begin
    //MapView.Lines.Add('Destory');
    Png.LoadFromFile(getcurrentdir() + '\data\Magic\104.png');
    p:=1;
    q:=3;
  end;
  5: ;//MapView.Lines.Add('Miss');
  6:
  begin
    //MapView.Lines.Add('Defence');
    Png.LoadFromFile(getcurrentdir() + '\data\Magic\101.png');
    p:=0;
    q:=3;
  end;
  7: ;//MapView.Lines.Add('');
  8: ;//MapView.Lines.Add('Back');
  9: ;//MapView.Lines.Add('Draw');
  10: ;//MapView.Lines.Add('Health');
  end;
  AttackChoose := n;
  begin
    hNum:=32*32;
    if HitChance then r:=Rect(32*(Num-2)-16,32*4+8,32*(Num-2)+48,32*4+72)
    else r:=Rect(16,32*4+8,32*2+16,32*6+8);
    for k := 1 to q do
    begin
      BmpCopy.Canvas.CopyRect(Rect(0,0,64,64),Map.Canvas,r);
      Map.Canvas.Draw(hNum,hNum,BmpCopy);
      Map.Canvas.Draw(hNum-64*(k-1),hNum-64*p,Png);
      Bmp.Canvas.CopyRect(Rect(0,0,64,64),Map.Canvas,Rect(hNum,hNum,hNum+64,hNum+64));
      if HitChance then
      begin
        Map.Canvas.Draw(32*(Num-2)-16,32*4+8,Bmp);
        Delay(40);
        Map.Canvas.Draw(32*(Num-2)-16,32*4+8,BmpCopy);
      end
      else
      begin
        Map.Canvas.Draw(16,32*4+8,Bmp);
        Delay(40);
        Map.Canvas.Draw(16,32*4+8,BmpCopy);
      end;
    end;
    Delay(100);
  end;
  Png.Free;
  Bmp.Free;
  BmpCopy.Free;
end;

procedure Tr.Attack(n,Turn:Integer);
var
  b:Boolean;
  Harm,Extra,m,s:Integer;
  Sd: Boolean;
  Label Again,Miss;
begin
  Sd := False;
  LifeBack[0] := FightArray[0][1];
  LifeBack[1] := FightArray[1][1];
  if n=0 then
  begin
    m:=1;
    HitChance:=True;
  end
  else
  begin
    m:=0;
    HitChance:=False;
  end;
  Delay(125);
  b:=False;
  if Magic(n) then
  begin
    if (Check(158,n))And(Ceil(Turn/3)=Trunc(Turn/3)) then //能量
    begin
      FightArray[n][5]:=FightArray[n][5]+Trunc(FightNum[n][5]/20);
      FightArray[n][6]:=FightArray[n][6]+Trunc(FightNum[n][6]/20);
    end;
    if Check(152,n) then //魔爆
    begin
      if FightArray[n][5]<=2*FightNum[n][5] then
        FightArray[n][5]:=FightArray[n][5]+Trunc(FightNum[n][5]/20);
    end;
    if Check(153,n) then //灵噬
    begin
      s:=Trunc(FightArray[m][6]/30);
      FightArray[m][6]:=FightArray[m][6]-s;
      FightArray[n][6]:=FightArray[n][6]+s;
    end;
    Harm:=FightArray[n][5]-FightArray[m][6];
    if (Check(154,n))And(Random(100)<10) then //湮灭
    begin
      Harm:=Harm+5*FightArray[m][5];
      SoundPlay('Destory');
      Sd := True;
      AttackFlash(4);
    end
    else AttackFlash(3);
    if Check(156,n) then //震荡
      Harm:=Trunc(Harm*(Random(150)/100+1/2));
    if Check(155,n) then //灵魄
      FightArray[n][2]:=FightArray[n][2]+Trunc(Harm/5);
    if Check(157,n) then //破碎
    begin
      Harm:=Trunc(Harm*3/2);
      FightArray[n][1]:=FightArray[n][1]-Trunc(Harm/10);
    end;
    if Check(303,m) then Harm:=2*Harm; //强守
    if Check(352,m) then Harm:=Trunc(Harm/2); //灵护
    if Harm < 0 then Harm := 0;
    FightArray[n][2]:=FightArray[n][2]-Ceil(Sqrt(Harm));
    if FightArray[n][2]<0 then
    begin
      Harm:=Trunc(Harm/3);
      FightArray[n][2]:=0;
    end;
    if Check(351,m) then //魔甲
    begin
      FightArray[m][1]:=FightArray[m][1]-Trunc(Harm/2);
      FightArray[m][2]:=FightArray[m][2]-Trunc(Harm/2);
      if FightArray[n][2]<0 then FightArray[n][2]:=0;
    end
    else FightArray[m][1]:=FightArray[m][1]-Harm;
    if FightArray[m][1]<0 then FightArray[m][1]:=0;
    if Not(Sd) then SoundPlay('Magic');
  end
  else
  begin
    if (Check(353,m))And((Turn mod 5)=0) then //结界
    begin
      SoundPlay('Miss');
      Sd := True;
      AttackFlash(5);//Miss
      goto Miss;
    end;
    if (Check(103,n))And(Random(100)<20) then b:=True else b:=False; //连击
    if Check(111,n)And(Turn=1) then b:=True; //疯狂
    Again:
    if Not(Check(105,n))And(Random(100)>FightArray[n][13]-FightArray[m][14]) then //必中
    begin
      SoundPlay('Miss');
      Sd := True;
      AttackFlash(5);//Miss
      goto Miss;
    end;
    if Check(104,n) then //破甲
    Harm:=FightArray[n][3]-Trunc(FightArray[m][4]*4/5)
    else Harm:=FightArray[n][3]-FightArray[m][4];
    Extra:=Trunc(FightArray[n][3]*FightArray[n][3]/(10*(FightArray[n][3]+FightArray[m][4])));
    //Extra:=0;
    if Check(304,m) then Harm:=Trunc(Harm/2); //铁壁
    if Check(302,m)And(Random(100)<20) then //格挡
    begin
      SoundPlay('Block');
      Sd := True;
      Harm:=0;
      Extra:=0;
    end;
    if Check(303,m) then Extra:=0; //强守
    if Check(352,m) then //灵护
    begin
      Harm:=Trunc(Harm*4/5);
      Extra:=2*Extra;
    end;
    if Check(106,n) then //强击
    begin
      if FightArray[n][3]<=2*FightNum[n][3] then
        FightArray[n][3]:=FightArray[n][3]+Trunc(FightNum[n][3]/20);
    end;

    if (Check(102,n))And(Random(100)<(20+FightArray[n][12]))Or(Random(100)<FightArray[n][12]) then //必杀
    begin
      SoundPlay('Double');
      Sd := True;
      Harm:=2*Harm;
      Extra:=2*Extra;
      AttackFlash(2);
    end
    else
    begin
      if Check(202,n) then FightArray[n][12]:=FightArray[n][12]+5;
      if (Harm=0)And(Extra=0) then AttackFlash(6) else AttackFlash(1);
    end;
    if Check(108,n) then //衰竭
    begin
      Harm:=Harm+Trunc(FightArray[m][1]/20)
    end;
    if Check(109,n) then //损毁
    begin
      FightArray[m][2]:=FightArray[m][2]-Trunc(Harm/2);
      if FightArray[m][2]<0 then FightArray[m][2]:=0;
    end;
    if Check(306,m) then
    begin
      FightArray[n][1]:=FightArray[n][1]-Trunc((Harm+Extra)/5); //反震
      AttackFlash(8);
    end;
    if FightArray[n][1]<0 then FightArray[n][1]:=0;
    if Check(101,n) then //吸血
    begin
      if Not(Sd) then SoundPlay('Blood');
      FightArray[n][1]:=FightArray[n][1]+Trunc(Harm/5);
      //AttackFlash(9);
    end
    else if Not(Sd) then SoundPlay('Sword');
    if Harm < 0 then Harm := 0;
    FightArray[m][1]:=FightArray[m][1]-(Harm+Extra);
    if FightArray[m][1]<0 then FightArray[m][1]:=0;
    Miss:
    if b then
    begin
      b:=False;
      goto Again;
    end;
  end;
  if (Check(204,n))And(FightArray[n][1]<>0) then //活络
  begin
    FightArray[n][1]:=FightArray[n][1]+Ceil((FightArray[n][3]+FightArray[n][4])/20);
    if Magic(n) then FightArray[n][2]:=FightArray[n][2]+Ceil((FightArray[n][5]+FightArray[n][6])/50);
    //AttackFlash(10);
  end;
  Map.Canvas.Draw(32*2,32*4,BmpFight1);
  Map.Canvas.Draw(0,32*5+24,BmpFight2);
  FightPrint;
  BmpLifeBack1.Canvas.CopyRect(Rect(0,0,64,64),Map.Canvas,Rect(32*(Num-2)-16,32*4+8,32*(Num-2)+48,32*4+72));
  BmpLifeBack2.Canvas.CopyRect(Rect(0,0,64,64),Map.Canvas,Rect(16,32*4+8,32*2+16,32*6+8));
  TimeAllow := True;
  Delay(300);
end;

procedure Tr.GameOver;
begin
  SoundPlay('GameOver', '.mp3');
  //ShowMessage('Game Over');
  Menu.Visible := True;
  Map.Visible := False;
  StateMap.Visible := False;
  MenuChoose := True;
  Timer.Enabled := False;
  StartNum;
  StartCreate;
  MainMenu;
end;

procedure Tr.GetWeapon(p, q : Integer);
var
  l, m, n : Integer;
begin
  case MapArray[p,q] of
    301..304: ;
    311..314: ;
    321..324: ;
    331..334: ;
    351..353: ;
    361..363: ;
    371..373: ;
    401..402: ;
    411..412: ;
    421..422: ;
    431..432: ;
    441..442: ;
    451..455: ;
    461..462:
    begin
      l := 0;
      repeat
        l := l + 1;
      until WeaponItem[l][1] = 0;
      //1.种类 2.名称 3.星级 4.攻击/防御 5.宝石1 6.宝石2 7.宝石3
      m := Random(5);
      if Random(2) = 0 then
      begin
        if MapArray[p, q] = 461 then m := m + 201
        else m := m + 221;
      end
      else
      begin
        if MapArray[p, q] = 461 then m := m + 211
        else m := m + 231;
      end;
      WeaponItem[l][1] := m;
      WeaponItem[l][2] := 0;
      case Random(100) of
        0..49: n := 0;
        50..79: n := 1;
        80..94: n := 2;
        95..99: n := 3;
      end;
      if (MapArray[p, q] = 462)And(n > 2) then n := 2;
      WeaponItem[l][3] := n;
      n := MonsterBase[(WeaponItem[l][1] - 200) div 10 + 3] div 5;
      m := n + Random((n * 30) div 100 * 2 + 1) - (n * 30) div 100;
      m := m + Random((n * 20) div 100 * 2 + 1) - (n * 20) div 100;
      m := m + Random((n * 10) div 100 * 2 + 1) - (n * 10) div 100;
      WeaponItem[l][4] := m;
      WeaponItem[l][5] := 0;
      WeaponItem[l][6] := 0;
      WeaponItem[l][7] := 0;
      MsgView('你获得了一件装备');
      //ShowMessage(IntToStr(n) + ' ' + IntToStr(m));
    end;
    463..464:
    begin
      l := 0;
      repeat
        l := l + 1;
      until GemItem[l] = 0;
        n := Random(35) + 1;
        GemItem[l] := GemArray[n]
    end;
  end;

end;

function Tr.Fight(p,q:Integer): Boolean;
var
  Turn:Array[0..1] of Integer;
begin
  KeyAble := False;
  FightQuit := True;
  NumFight:=MapArray[p,q];
  BmpFight.Canvas.CopyRect(Rect(0,0,32*Num,32*(Num-8)),Map.Canvas,Rect(0,32*4,32*Num,32*(Num-4)));
  GetTxt;
  GetRecord;
  StartFight;
  BmpFight1.Canvas.CopyRect(Rect(0,0,32*(Num-4),32+24),Map.Canvas,Rect(32*2,32*4,32*(Num-2),32*5+24));
  BmpFight2.Canvas.CopyRect(Rect(0,0,32*Num,32*(Num-10)+8),Map.Canvas,Rect(0,32*5+24,32*Num,32*(Num-4)));
  FightPrint;
  Allow:=True;
  FightAllow:=True;
  Delay(100);
  Turn[0]:=0;
  Turn[1]:=0;
  if (Check(112,0))And(Not(Check(112,1))) then Turn[0]:=1
  else if (Check(112,1))And(Not(Check(112,0))) then Turn[1]:=1
  else if FightArray[0][15]<FightArray[1][15] then Turn[1]:=1
  else Turn[0]:=1;
  //MapView.Lines.Add(IntToStr(Turn[0])+' '+IntToStr(Turn[1]));
  while True do
  begin
    if Turn[0]>Turn[1] then Attack(0,Turn[0]) else Attack(1,Turn[1]);
    if FightArray[1][1]<=0 then Over := True else Over := False;
    if Not(FightQuit) then Over := True;
    if Over then break;
    if FightArray[0][1]<=0 then
    begin
      HeroState[1]:=FightArray[1][1];
      HeroState[2]:=FightArray[1][2];
      HeroState[16]:=HeroState[16]+FightArray[0][16];
      HeroState[17]:=HeroState[17]+FightArray[0][17];
      //MapView.Lines.Add('Win!');
      break;
    end;
    if Turn[0]>Turn[1] then Attack(1,Turn[0]) else Attack(0,Turn[1]);
    if FightArray[1][1]<=0 then Over := True else Over := False;
    if Not(FightQuit) then Over := True;
    if Over then break;
    if FightArray[0][1]<=0 then
    begin
      HeroState[1]:=FightArray[1][1];
      HeroState[2]:=FightArray[1][2];
      HeroState[16]:=HeroState[16]+FightArray[0][16];
      HeroState[17]:=HeroState[17]+FightArray[0][17];
      //MapView.Lines.Add('Win!');
      break;
    end;
    //MapView.Lines.Add(IntToStr(Turn[0])+' '+IntToStr(Turn[1])+
    //' '+IntToStr(FightArray[0][1])+' '+IntToStr(FightArray[1][1]));
    Turn[0]:=Turn[0]+1;
    Turn[1]:=Turn[1]+1;
  end;
  Allow:=False;
  FightAllow:=False;
  Map.Canvas.Draw(0,32*4,BmpFight);
  KeyAble := True;
  if (Over)And(Not(FightQuit)) then
  begin
    if HeroState[1] > FightArray[1][1] then HeroState[1] := FightArray[1][1];
    if HeroState[2] > FightArray[1][2] then HeroState[2] := FightArray[1][2];
    Result := False;
    if FightQuit then GameOver;
  end
  else
  begin
    GetWeapon(p, q);
    MapArray[p,q]:=15;
    Result := True;
  end;
end;

procedure Tr.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Halt;
end;

procedure Tr.FormCreate(Sender: TObject);
begin
  StartNum;
  StartCreate;
  MainMenu;
  StartSound(1, 57);
end;

procedure Tr.FormDestroy(Sender: TObject);
begin
  Over := True;
  SoundStop('FrontSound');
  SoundStop('BackSound');
end;

procedure Tr.StartNum;
begin
  Num := 13;
  BigNum := 3000;
  HardNum := 5;
  Floor := -10;
  WallNum := 3;
  Time := 0;
  Allow := False; //战斗画面区域禁止地图怪物动画
  FightAllow := False; //战斗开启
  EquipChance := False; //装备栏开启
  EquipChoose := False; //装备选择
  EquipOrGem := True; //宝石/装备选择
  ItemChance := False;
  GemSet := False; //宝石镶嵌状态开启/关闭
  GemChoose := False; //宝石选择
  GemSpace := False;
  LifeChoose := False; //生命显示开启
  TimeAllow := False;
  KeyAble := True;
  MonsterBook := False;
  MoveChance := True; //移动许可
  MoveAllow := False;
  Wall := 3;
  MsgLock := 0;
  FindFloor := 0;
  BookFloor := 0;
  MenuNum := 1;
  MenuChoose := True;
  FightMenuNum := 1;
  FightMenu := False;
  MoveKey := 0;
  SaveTime := 3;
end;

procedure Tr.SoundTimer(Sender: TObject);
var
  s: String;
begin
  case BackMusic of
    1: s := 'FrontSound';
    2: s := 'BackSound';
  end;
  SoundPlay(s, '.mp3');
end;

procedure Tr.StartCreate;
var
  i:Integer;
begin
  Menu.Left := 80;
  Menu.Top := 20;
  Menu.Width := 32 * 20 + 2;
  Menu.Height := 32 * 14;
  StateMap.Left := 112;
  StateMap.Top := 52;
  Map.Left := 114 + 32 * 6;
  Map.Top := 52;
  Timer.Enabled:=False;
  MenuNum := 1;
  AllStart;
  PngFloor:=TPngImage.Create;
  PngWall:=TPngImage.Create;
  //WallRefresh;
  for i := 100 to 299 do Item[i]:=0;
  Item[101]:=3;
  Item[102]:=3;
  Item[103]:=3;
  Item[131]:=3;
  Item[132]:=3;
  Item[133]:=3;

  StateMap.Width:=6*32;
  StateMap.Height:=Num*32;
  BmpFight:=TBitMap.Create;
  BmpFight.Width:=32*Num;
  BmpFight.Height:=32*(Num-8);
  BmpFight1:=TBitMap.Create;
  BmpFight1.Width:=32*(Num-4);
  BmpFight1.Height:=32+24;
  BmpFight2:=TBitMap.Create;
  BmpFight2.Width:=32*Num;
  BmpFight2.Height:=32*(Num-10)+8;
  BmpLifeBack1:=TBitMap.Create;
  BmpLifeBack1.Width:=64;
  BmpLifeBack1.Height:=64;
  BmpLifeBack2:=TBitMap.Create;
  BmpLifeBack2.Width:=64;
  BmpLifeBack2.Height:=64;
  MsgBmp:=TBitMap.Create;
  MsgBmp.Width:=32 * (Num - 4) + 4;
  MsgBmp.Height:=32 + 4;
  MsgBmp.Canvas.Brush.Color := clGreen;
  MsgBmp.Canvas.Rectangle(-1, -1, 32 * (Num - 4) + 5, 32 + 5);
  MsgBmp.Canvas.Brush.Color := clYellow;
  MsgBmp.Canvas.Rectangle(0, 0, 32 * (Num - 4) + 4, 32 + 4);
  PngFloor.LoadFromFile(getcurrentdir() + '\data\001.png');
  for i := 1 to Num - 4 do MsgBmp.Canvas.Draw(32*(i-1) + 2, 0 + 2, PngFloor);

  TimeNum := 1;
  LifeTime := 1;

  for i := 1 to 18 do
  begin
    HeroState[i] := HeroStart[i];
    MonsterBase[i] := MonsterStart[i];
  end;

  WeaponEquip[1] := 0;
  WeaponEquip[2] := 0;

  WeaponItem[1][1] := 201;
  WeaponItem[2][1] := 211;
  WeaponItem[3][1] := 221;
  WeaponItem[4][1] := 231;
  WeaponItem[1][3] := 1;
  WeaponItem[2][3] := 1;
  WeaponItem[3][3] := 1;
  WeaponItem[4][3] := 1;
  WeaponItem[1][4] := 4 + Random(3);
  WeaponItem[2][4] := 4 + Random(3);
  WeaponItem[3][4] := 4 + Random(3);
  WeaponItem[4][4] := 4 + Random(3);

  for i := 1 to 28 do GemItem[i]:=0;
  GemItem[1] := 105;
  GemItem[2] := 302;

end;

procedure Tr.MsgView(str: String);
var
  i,lock: Integer;
  l: Integer;
  r: TRect;
  s: String;
  Bmp: TBitMap;
begin
  Timer.Enabled:=False;
  Bmp:=TBitMap.Create;
  Bmp.Width:=32 * (Num - 4);
  Bmp.Height:=32;
  r := Rect(32 * 2, 32 * (Num div 2), 32 * (Num - 2), 32 * ((Num div 2) + 1));
  Bmp.Canvas.CopyRect(Rect(0, 0, 32 * (Num - 4), 32), Map.Canvas, r);
  Map.Canvas.Font.Name:='楷体';
  Map.Canvas.Font.Style:=[fsBold];
  Map.canvas.Brush.style:=bsclear;
  Map.Canvas.Font.Size:=12;
  Map.Canvas.Font.Color := clwhite;
  l := 14;
  MsgLock := Ceil(Length(str) / l);
  lock := MsgLock;
  for i := 1 to Ceil(Length(str) / l) do
  begin
    Map.Canvas.CopyRect(r, MsgBmp.Canvas, Rect(0, 0, 32 * (Num - 4) + 4, 32 + 4));
    s := MidStr(str, l * (i - 1) + 1, l);
    Map.Canvas.TextOut((32*Num-17*Length(s)) div 2, 32*(Num div 2)+8, s);
    while MsgLock = lock do Delay(10);
    lock := MsgLock;
  end;
  Map.Canvas.Draw(32 * 2, 32 * (Num div 2), Bmp);
  Bmp.Free;
  Timer.Enabled := True;
end;

procedure SkillRefresh;
begin
  HeroState[7] := WeaponItem[WeaponEquip[1]][5];
  HeroState[8] := WeaponItem[WeaponEquip[1]][6];
  HeroState[9] := WeaponItem[WeaponEquip[1]][7];
  HeroState[10] := WeaponItem[WeaponEquip[2]][5];
  HeroState[11] := WeaponItem[WeaponEquip[2]][6];
end;

procedure Neaton(p, q : Integer);
var
  i, j : Integer;
begin
  if p = 0 then
  begin
    for i := q to 23 do
    begin
      for j := 1 to 7 do
        WeaponItem[i][j] := WeaponItem[i + 1][j];
    end;
  end
  else
  begin
    for i := q to 27 do
      GemItem[i] := GemItem[i + 1];
  end;
end;

function Tr.GemCheck(n, k: Integer): Boolean; //n.镶嵌物品 k.镶嵌宝石
begin
  {if (k > 200)And(k < 300) then
  begin
    Result := True;
    if (WeaponItem[4 * page + pageNum][5] > 200)And(WeaponItem[4 * page + pageNum][5]< 300) then Result := False;
    if (WeaponItem[4 * page + pageNum][6] > 200)And(WeaponItem[4 * page + pageNum][6]< 300) then Result := False;
    if (WeaponItem[4 * page + pageNum][7] > 200)And(WeaponItem[4 * page + pageNum][7]< 300) then Result := False;
    if Not(Result) then MsgView('已经镶嵌过通用宝石了！');
  end
  else}
  begin
    Result := False;
    case n of
      201..205: if (k > 100)And(k < 150) then Result := True;
      211..215: if (k > 300)And(k < 350) then Result := True;
      221..225: if (k > 150)And(k < 200) then Result := True;
      231..235: if (k > 350)And(k < 400) then Result := True;
    end;
    if (Result)Or(k > 200)And(k < 300) then
    begin
      Result := True;
      if WeaponItem[4 * page + pageNum][5] = k then Result := False;
      if WeaponItem[4 * page + pageNum][6] = k then Result := False;
      if WeaponItem[4 * page + pageNum][7] = k then Result := False;
      if Not(Result) then MsgView('已经镶嵌过该宝石了！');
    end
    else Msgview('宝石种类不匹配！');
  end;
end;

procedure Tr.WallRefresh;
begin
  case Wall of
    3:
    begin
      PngFloor.LoadFromFile(getcurrentdir() + '\data\001.png');
      PngWall.LoadFromFile(getcurrentdir() + '\data\011.png');
    end;
    4:
    begin
      PngFloor.LoadFromFile(getcurrentdir() + '\data\001.png');
      PngWall.LoadFromFile(getcurrentdir() + '\data\012.png');
    end;
    5:
    begin
      PngFloor.LoadFromFile(getcurrentdir() + '\data\001.png');
      PngWall.LoadFromFile(getcurrentdir() + '\data\013.png');
    end;
  end;
end;

procedure Tr.DestoryWall(p,q:Integer);
var
  k,hNum:Integer;
  Bmp:TBitMap;
begin
  SoundPlay('DestoryWall');
  Bmp:=TBitMap.Create;
  hNum:=32*32;
  Bmp.Width:=32;
  Bmp.Height:=32;
  for k := 0 to 7 do
  begin
    Map.Canvas.Draw(hNum,hNum,PngFloor);
    Map.Canvas.Draw(hNum,hNum+4*k,PngWall);
    Bmp.Canvas.CopyRect(Rect(0,0,32,32),Map.Canvas,Rect(hNum,hNum,hNum+32,hNum+32));
    Map.Canvas.Draw(32*(p-1),32*(q-1),Bmp);
    Delay(50);
  end;
  Map.Canvas.Draw(32*(p-1),32*(q-1),PngFloor);
  MapArray[p,q]:=15;
  Bmp.Free;
end;

procedure Tr.SaveGame;
var
  pFile: TextFile;
  i, j: Integer;
  c: Char;
  k: Integer;
begin
  c := ' ';
  AssignFile(pFile, getcurrentdir() + '\data\Save.txt');
  ReWrite(pFile);
  Write(pFile, Floor, c, xHero, c, yHero, c, kHero, c, HeroFace, c, Wall, c, SaveTime, c);
  for i := 100 to 299 do Write(pFile, Item[i], c);
  for i := 1 to 2 do Write(pFile, WeaponEquip[i], c);
  for i := 1 to 24 do
    for j := 1 to 7 do
      Write(pFile, WeaponItem[i,j], c);
  for i := 1 to 24 do Write(pFile, GemItem[i], c);
  for i := 1 to 18 do Write(pFile, HeroStart[i], c);
  for i := 1 to 18 do Write(pFile, MonsterBase[i], c);
  for i := 0 to Num+1 do
    for j := 0 to Num+1 do
      for k := 0 to 9 do
        Write(pFile, FloorArray[k,i,j], c);
  CLoseFile(pFile);
  {Floor: Integer=-10;
  Item: Array[100..299] of Integer;
  WeaponEquip: Array[1..2] of Integer;
  WeaponItem: Array[1..24] of Array[1..7] of Integer;
  GemItem: Array[1..28] of Integer;
  xHero,yHero,kHero: Integer;
  HeroFace: Integer;
  HeroStart: Array[1..18] of Integer=(2000,500,20,20,20,20,0,0,0,0,0,0,100,0,20,0,0,0);
  MonsterBase: Array[1..18] of Integer;
  Wall;
  SaveTime}
end;

procedure Tr.ReadGame;
var
  pFile: TextFile;
  pStr: String;
  i, j, k: Integer;
  c: Char;
begin
  StartNum;
  StartCreate;
  Menu.Visible := False;
  Map.Visible := True;
  StateMap.Visible := True;
  MenuChoose := False;
  Timer.Enabled := True;
  SoundStop('FrontSound');
  StartSound(2, 90);
  AssignFile(pFile, getcurrentdir() + '\data\Save.txt');
  Reset(pFile);
  Read(pFile, Floor, c, xHero, c, yHero, c, kHero, c, HeroFace, c, Wall, c, SaveTime, c);
  WallRefresh;
  for i := 100 to 299 do Read(pFile, Item[i], c);
  for i := 1 to 2 do Read(pFile, WeaponEquip[i], c);
  for i := 1 to 24 do
    for j := 1 to 7 do
      Read(pFile, WeaponItem[i,j], c);
  for i := 1 to 24 do Read(pFile, GemItem[i], c);
  for i := 1 to 18 do Read(pFile, HeroStart[i], c);
  for i := 1 to 18 do Read(pFile, MonsterBase[i], c);
  for i := 0 to Num+1 do
    for j := 0 to Num+1 do
      for k := 0 to 9 do
        Read(pFile, FloorArray[k,i,j], c);
  CopyMap(kHero);
  MapCreate;
  //pStr := IntToStr(Floor)+c+IntToStr(xHero)+c+IntToStr(yHero)+c+IntToStr(kHero);
  //ShowMessage(pStr);
  CLoseFile(pFile);
end;

procedure Tr.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  p,q,hNum,ls:Integer;
  Check: Boolean;
  Label GemEnd;
begin
  if MenuChoose then
  begin
    case Key of
      32:
      begin
        case MenuNum of
          1:
          begin
            StartNum;
            StartCreate;
            CreateMap;
            MapCreate;
            Menu.Visible := False;
            Map.Visible := True;
            StateMap.Visible := True;
            ItemMenu;
            MenuChoose := False;
            Timer.Enabled := True;
            SoundStop('FrontSound');
            StartSound(2, 90);
          end;
          2: ;
          3: Halt;
        end;
      end;
      38: if MenuNum > 1 then MenuNum := MenuNum - 1;
      40: if MenuNum < 3 then MenuNum := MenuNum + 1;
    end;
    if Key <> 32 then MainMenu;
    exit;
  end;

  if MsgLock <> 0 then //对话框屏蔽其它信号
  begin
    if Key = 32 then MsgLock := MsgLock - 1;
    exit;
  end;

  if Key = 27 then
  begin
    FightMenu := Not(FightMenu);
    if FightMenu then FightMenuNum := 1;
  end;
  if (FightMenu)And(Not(FightAllow)) then
  begin
    case Key of
      32:
      begin
        case FightMenuNum  of
          1: FightMenu := False;
          2:
          begin
            if SaveTime <= 0 then
            begin
              MsgView('存档次数已使用完！');
              exit;
            end;
            Dec(SaveTime);
            MsgView('存档成功，还剩' + IntToStr(SaveTime) + '次');
            SaveGame;
          end;
          3:
          begin
            MsgView('读档成功');
            ReadGame;
          end;
          4:
          begin
            Menu.Visible := True;
            Map.Visible := False;
            StateMap.Visible := False;
            MenuChoose := True;
            Timer.Enabled := False;
            SoundStop('BackSound');
            StartSound(1, 57);
          end;
        end;
      end;
      38: if FightMenuNum > 1 then FightMenuNum := FightMenuNum - 1;
      40: if FightMenuNum < 4 then FightMenuNum := FightMenuNum + 1;
    end;
    ItemMenu;
    exit;
  end;
  if Key = 81 then FightQuit := False;
  if Not(KeyAble) then exit;
  if Key = 86 then
  begin
    MonsterBook := Not(MonsterBook);
    ItemMenu;
    Exit;
  end;
  if (MonsterBook)And(Key = 66) then
  begin
    BookPage := BookPage + 1;
    BookPage := BookPage mod BookPageMax;
  end;

  if Key = 81 then
  begin
    if EquipChoose then EquipChoose := False
    else if GemChoose then GemChoose := False
    else if (EquipChance)And(Not((GemSet)And(GemSpace))) then
    begin
      EquipChance := False;
      MoveChance := True;
      Map.Canvas.Draw(0,32*4,BmpFight);
      Allow := False;
    end;
  end;

  if Key = 73 then  //I进入装备界面
  begin
    if Not(EquipChance) then
    begin
      page := 0;
      pageNum := 1;
      GemPage := 0;
      GemNum := 1;
      Allow := True;
      BmpFight.Canvas.CopyRect(Rect(0,0,32*Num,32*(Num-8)),Map.Canvas,Rect(0,32*4,32*Num,32*(Num-4)));
      EquipChance := True;
      MoveChance := False;
    end;
  end;
  if EquipChance then  //选择装备栏/宝石栏
  begin
    if (Key = 38)And(Not(EquipChoose))And(Not(GemChoose))And(Not(GemSet)) then
    begin
      EquipOrGem := True;
    end;
    if (Key = 40)And(Not(EquipChoose)And(Not(GemChoose))) then
    begin
      EquipOrGem := False;
    end;
    if (Key = 32)And(WeaponItem[4 * page + pageNum][1] <> 0)And(Not(EquipChoose))And(EquipOrGem) then
    begin
      EquipChoose := True;
      EquipNum := 0;
    end;
    if (Key = 32)And(GemItem[7 * GemPage + GemNum] <> 0)And(Not(GemChoose))And(Not(EquipOrGem))And(Not(GemSpace)) then
    begin
      GemChoose := True;
      GemNumber := 0;
    end;
    if (Key = 32)And(EquipChoose) then
    begin
      case EquipNum of
      0: EquipNum := 1;
      1:
      begin
        MsgView(IntToStr(WeaponItem[4 * page + pageNum][4]) + '    ' +
                SkillName(WeaponItem[4 * page + pageNum][5]) + '  ' +
                SkillName(WeaponItem[4 * page + pageNum][6]) + '  ' +
                SkillName(WeaponItem[4 * page + pageNum][7]));//View
      end;
      2:
      begin
        SoundPlay('ChangeWeapon');
        ls := (WeaponItem[4 * page + pageNum][1]-200) div 10 + 3;
        if WeaponEquip[1] = 4 * page + pageNum then
        begin
          HeroState[18] := 0;
          WeaponEquip[1] := 0;
          HeroState[ls] := HeroState[ls] - WeaponItem[4 * page + pageNum][4];
        end
        else
        begin
          if (ls = 3)Or(ls = 5) then
          begin
            case ls of
              3: HeroState[18] := 0;
              5: HeroState[18] := 1;
            end;
            case WeaponItem[WeaponEquip[1]][1] of
              201..205: HeroState[3] := HeroState[3] - WeaponItem[WeaponEquip[1]][4];
              221..225: HeroState[5] := HeroState[5] - WeaponItem[WeaponEquip[1]][4];
            end;
            WeaponEquip[1] := 4 * page + pageNum;
            HeroState[ls] := HeroState[ls] + WeaponItem[4 * page + pageNum][4];
          end;
        end;
        if WeaponEquip[2] = 4 * page + pageNum then
        begin
          WeaponEquip[2] := 0;
          HeroState[ls] := HeroState[ls] - WeaponItem[4 * page + pageNum][4];
        end
        else
        begin
          if (ls = 4)Or(ls = 6) then
          begin
            case WeaponItem[WeaponEquip[2]][1] of
              211..215: HeroState[4] := HeroState[4] - WeaponItem[WeaponEquip[2]][4];
              231..235: HeroState[6] := HeroState[6] - WeaponItem[WeaponEquip[2]][4];
            end;
            WeaponEquip[2] := 4 * page + pageNum;
            HeroState[ls] := HeroState[ls] + WeaponItem[4 * page + pageNum][4];
          end;
        end;
        EquipChoose := False;
      end;
      3:
      if Not(GemSet) then
      begin
        GemSet := True;
        EquipOrGem := False;
        EquipChoose := False;
        GemSpace := False;
      end;
      4: //Drop
      begin
        if (WeaponEquip[1] = 4 * page + pageNum) then WeaponEquip[1] := 0
        else if (WeaponEquip[1] > 4 * page + pageNum) then WeaponEquip[1] := WeaponEquip[1] - 1;
        if (WeaponEquip[2] = 4 * page + pageNum) then WeaponEquip[2] := 0
        else if (WeaponEquip[2] > 4 * page + pageNum) then WeaponEquip[2] := WeaponEquip[2] - 1;
        Neaton(0, 4 * page + pageNum);
        EquipChoose := False;
      end;
      5: EquipChoose := False;
      end;
      SkillRefresh;
    end;
    if (Key = 32)And(GemChoose) then
    begin
      case GemNumber of
      0: GemNumber := 1;
      1: MsgView(SkillName(GemItem[7 * GemPage + GemNum]) + '  ' + SkillIntroduce(GemItem[7 * GemPage + GemNum])); //View
      2: //Drop
      begin
        Neaton(1, 7 * GemPage + GemNum);
        GemChoose := False;
      end;
      3: GemChoose := False; //Cancle
      end;
    end;
    if EquipChoose then
    begin
      case Key of
      38: if EquipNum > 1 then EquipNum := EquipNum - 1;
      40: if EquipNum < 5 then EquipNum := EquipNum + 1;
      end;
    end
    else if GemChoose then
    begin
      case Key of
      38: if GemNumber > 1 then GemNumber := GemNumber - 1;
      40: if GemNumber < 3 then GemNumber := GemNumber + 1;
      end;
    end
    else
    begin
      case Key of  //选择装备/宝石
      81:  //取消
      if GemSet then
      if Not(GemSpace) then GemSpace := True
      else
      begin
        GemSet := False;
        EquipOrGem := True;
        //EquipChoose := True;
        GemSpace := False;
      end;
      32:  //镶嵌确认
      if GemSet then
      if Not(GemSpace) then GemSpace := True
      else
      begin
        Check := True;
        if (WeaponItem[4 * page + pageNum][5] <> 0) then
        begin
          if (WeaponItem[4 * page + pageNum][6] <> 0) then
          begin
            if (WeaponItem[4 * page + pageNum][7] <> 0) then
            begin
              Check := False;
            end
            else if(WeaponItem[4 * page + pageNum][3] > 2) then
            begin
              if Not(GemCheck(WeaponItem[4 * page + pageNum][1], GemItem[7 * GemPage + GemNum])) then goto GemEnd;
              WeaponItem[4 * page + pageNum][7] := GemItem[7 * GemPage + GemNum];
              Neaton(1, 7 * GemPage + GemNum);
            end
            else Check := False;
          end
          else if (WeaponItem[4 * page + pageNum][3] > 1) then
          begin
            if Not(GemCheck(WeaponItem[4 * page + pageNum][1], GemItem[7 * GemPage + GemNum])) then goto GemEnd;
            WeaponItem[4 * page + pageNum][6] := GemItem[7 * GemPage + GemNum];
            Neaton(1, 7 * GemPage + GemNum);
          end
          else Check := False;
        end
        else if (WeaponItem[4 * page + pageNum][3] > 0) then
        begin
          if Not(GemCheck(WeaponItem[4 * page + pageNum][1], GemItem[7 * GemPage + GemNum])) then goto GemEnd;
          WeaponItem[4 * page + pageNum][5] := GemItem[7 * GemPage + GemNum];
          Neaton(1, 7 * GemPage + GemNum);
        end
        else Check := False;
        if Check then
        begin
          SoundPlay('SetGem');
          GemSet := False;
          EquipOrGem := True;
          //EquipChoose := True;
          GemSpace := False;
          GemEnd:
        end
        else MsgView('宝石槽已满！');
      end;
      37:
      if EquipOrGem then
      begin
        if (page <> 0)Or(pageNum <> 1) then pageNum := pageNum - 1;
        if pageNum < 1 then
        begin
          pageNum := pageNum + 4;
          page := page - 1;
        end;
      end
      else
      begin
        if (GemPage <> 0)Or(GemNum <> 1) then GemNum := GemNum - 1;
        if GemNum < 1 then
        begin
          GemNum := GemNum + 7;
          GemPage := GemPage - 1;
        end;
      end;
      39:
      if EquipOrGem then
      begin
        if (page <> 4)Or(pageNum <> 4) then pageNum := pageNum + 1;
        if pageNum > 4 then
        begin
          pageNum := pageNum - 4;
          page := page + 1;
        end;
      end
      else
      begin
        if (GemPage <> 5)Or(GemNum <> 7) then GemNum := GemNum + 1;
        if GemNum > 7 then
        begin
          GemNum := GemNum - 7;
          GemPage := GemPage + 1;
        end;
      end;
      end;
    end;
    Equip;
  end;
  if MoveChance then
  begin
    p := xHero;
    q := yHero;
    case Heroface of
    37: p := p-1;
    38: q := q-1;
    39: p := p+1;
    40: q := q+1;
    end;
    case Key of //物品使用(z)
      90:
      begin
        if (Wall = 3)And(MapArray[p][q] = 3)And(Item[131] > 0) then
        begin
          Item[131] := Item[131] - 1;
          DestoryWall(p,q);
        end;
        if (Wall = 4)And(MapArray[p][q] = 3)And(Item[132] > 0) then
        begin
          Item[132] := Item[132] - 1;
          DestoryWall(p,q);
        end;
        if (Wall = 5)And(MapArray[p][q] = 3)And(Item[133] > 0) then
        begin
          Item[133] := Item[133] - 1;
          DestoryWall(p,q);
        end;
        ItemMenu;
        Exit;
      end;
      65: DownFloor;
      83: if kHero < FindFloor then UpFloor;
    end;
  end;
  if (Key >= 37)And(Key <= 40) then
  begin
    if (MoveChance)And(Not(MoveAllow)) then
    begin
      MoveAllow := True;
      MoveKey := Key;
      Walk;
      MoveAllow := False;
    end
    else if MoveAllow then
    begin
        MoveKey := Key;
    end;
  end;
  ItemMenu;
end;

procedure Tr.UpFloor;
var
  i, j: Integer;
begin
  HeroFace := 40;
  if kHero=9 then
  begin
    SaveTime := 3;
    CreateMap;
    MapCreate;
    ItemMenu;
  end
  else
  begin
    CopyMap(kHero);
    kHero := kHero + 1;
    Floor := Floor + 1;
    if FindFloor < Floor mod 10 then FindFloor := Floor mod 10;
    CopyFloor(kHero);
    for i := 1 to Num do
      for j := 1 to Num do
      if MapArray[i,j]=1 then
      begin
        xHero:=i;
        yHero:=j;
      end;
    MapCreate;
  end;
  SoundPlay('Floor');
end;

procedure Tr.DownFloor;
var
  i, j: Integer;
begin
  HeroFace := 40;
  if kHero <> 0 then
  begin
    CopyMap(kHero);
    kHero := kHero - 1;
    Floor := Floor - 1;
    CopyFloor(kHero);
    for i := 1 to Num do
      for j := 1 to Num do
        if MapArray[i,j]=2 then
        begin
          xHero:=i;
          yHero:=j;
        end;
    MapCreate;
  end;
  SoundPlay('Floor');
end;

procedure Tr.HeroMove(n: Integer);
var
  a, b, c, k, x, y, hNum:Integer;
  Png:TPngImage;
  Bmp:TBitMap;
begin
  Png := TPngImage.Create;
  Bmp := TBitMap.Create;
  hNum:=32 * 16;
  Bmp.Width:=32;
  Bmp.Height:=32;
  case n of
    37:
    begin
      a := -1;
      b := 0;
      c := 1;
    end;
    38:
    begin
      a := 0;
      b := -1;
      c := 3;
    end;
    39:
    begin
      a := 1;
      b := 0;
      c := 2;
    end;
    40:
    begin
      a := 0;
      b := 1;
      c := 0;
    end;
  end;
  x := xHero + a;
  y := yHero + b;
  for k := 1 to 4 do
  begin
    if (MapArray[xHero,yHero]=1)Or(MapArray[xHero,yHero]=2) then
    begin
      Png.LoadFromFile(getcurrentdir() + '\data\magictower.png');
      Map.Canvas.Draw(hNum,hNum,PngFloor);
      Map.Canvas.Draw(hNum-32*(MapArray[xHero,yHero]-1),hNum-32*31,Png);
      Bmp.Canvas.CopyRect(Rect(0,0,32,32),Map.Canvas,Rect(hNum,hNum,hNum+32,hNum+32));
      Map.Canvas.Draw(32*(xHero-1),32*(yHero-1),Bmp);
    end
    else Map.Canvas.Draw(32*(xHero-1),32*(yHero-1),PngFloor);
    if (MapArray[x,y]=1)Or(MapArray[x,y]=2) then
    begin
      Png.LoadFromFile(getcurrentdir() + '\data\magictower.png');
      Map.Canvas.Draw(hNum,hNum,PngFloor);
      Map.Canvas.Draw(hNum-32*(MapArray[x,y]-1),hNum-32*31,Png);
      Bmp.Canvas.CopyRect(Rect(0,0,32,32),Map.Canvas,Rect(hNum,hNum,hNum+32,hNum+32));
      Map.Canvas.Draw(32*(x-1),32*(y-1),Bmp);
    end
    else Map.Canvas.Draw(32*(x-1),32*(y-1),PngFloor);
    Png.LoadFromFile(getcurrentdir() + '\data\Action\011.png');
    Bmp.Canvas.CopyRect(Rect(0,0,32,32),Map.Canvas,
    Rect(32*(xHero-1)+a*8*k,32*(yHero-1)+b*8*k,32*xHero+a*8*k,32*yHero+b*8*k));
    Map.Canvas.Draw(hNum,hNum,Bmp);
    Map.Canvas.Draw(hNum-32*(k mod 4),hNum-33*c,Png);
    Bmp.Canvas.CopyRect(Rect(0,0,32,32),Map.Canvas,Rect(hNum,hNum,hNum+32,hNum+32));
    Map.Canvas.Draw(32*(xHero-1)+a*8*k,32*(yHero-1)+b*8*k,Bmp);
    Delay(16);
  end;
  xHero := x;
  yHero := y;
  Png.Free;
  Bmp.Free;
end;

procedure Tr.Walk;
var
  p,q,hNum,ls: Integer;
  Png: TPngImage;
  Bmp: TBitMap;
  Check: Boolean;
begin
  Check := True;
  while True do
  begin
    Png:=TPngImage.Create;
    Bmp:=TBitMap.Create;
    hNum:=32*16;
    Bmp.Width:=32;
    Bmp.Height:=32;
    p:=xHero;
    q:=yHero;
    HeroFace := MoveKey;
    case MoveKey of
    37: p:=p-1;
    38: q:=q-1;
    39: p:=p+1;
    40: q:=q+1;
    end;
    while True do
    begin
      Png.LoadFromFile(getcurrentdir() + '\data\Action\011.png');
      if (MapArray[p,q]=3)Or((MapArray[p,q]>20)And(MapArray[p,q]<30)And(OpenDoor(p,q)=False)) then
      begin
        case MoveKey of
        37: ls := 1;
        38: ls := 3;
        39: ls := 2;
        40: ls := 0;
        end;
        Map.Canvas.Draw(hNum,hNum,PngFloor);
        if (MapArray[xHero,yHero]=1)Or(MapArray[xHero,yHero]=2) then
        begin
          Png.LoadFromFile(getcurrentdir() + '\data\magictower.png');
          Map.Canvas.Draw(hNum-32*(MapArray[xHero,yHero]-1),hNum-32*31,Png);
        end;
        Png.LoadFromFile(getcurrentdir() + '\data\Action\011.png');
        Map.Canvas.Draw(hNum,hNum-33*ls,Png);
        Bmp.Canvas.CopyRect(Rect(0,0,32,32),Map.Canvas,Rect(hNum,hNum,hNum+32,hNum+32));
        Map.Canvas.Draw(32*(xHero-1),32*(yHero-1),Bmp);
        Check := False;
        break;
      end
      else if (MapArray[p,q]>100)And(MapArray[p,q]<300) then GetItem(p,q)
      else if (MapArray[p,q]>300)And(MapArray[p,q]<500)And(Not(Fight(p,q))) then break;
      if MapArray[p,q] > 10 then SoundPlay('Move');
      HeroMove(MoveKey);
      if MapArray[xHero,yHero]=1 then DownFloor;
      if MapArray[xHero,yHero]=2 then UpFloor;
      break;
    end;
    if (MoveKey = 0)Or(Not(Check)) then break;
  end;
  MoveKey := 0;
end;

procedure Tr.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Key >= 37)And(Key <= 40)And(MoveAllow) then
  begin
    if MoveKey = Key then MoveKey := 0;//MoveCheck - 1;
  end;
end;


end.

