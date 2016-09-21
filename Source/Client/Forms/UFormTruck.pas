{*******************************************************************************
  作者: dmzn@163.com 2014-11-25
  描述: 车辆档案管理
*******************************************************************************}
unit UFormTruck;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFormBase, UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxMaskEdit, cxDropDownEdit,
  cxTextEdit, dxLayoutControl, StdCtrls, cxCheckBox, cxCalendar;

type
  TfFormTruck = class(TfFormNormal)
    EditTruck: TcxTextEdit;
    dxLayout1Item9: TdxLayoutItem;
    EditOwner: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    EditPhone: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    dxLayout1Group3: TdxLayoutGroup;
    CheckValid: TcxCheckBox;
    dxLayout1Item4: TdxLayoutItem;
    CheckVerify: TcxCheckBox;
    dxLayout1Item7: TdxLayoutItem;
    dxGroup2: TdxLayoutGroup;
    dxLayout1Item6: TdxLayoutItem;
    CheckUserP: TcxCheckBox;
    CheckVip: TcxCheckBox;
    dxLayout1Item8: TdxLayoutItem;
    dxLayout1Group2: TdxLayoutGroup;
    CheckGPS: TcxCheckBox;
    dxLayout1Item10: TdxLayoutItem;
    dxLayout1Group4: TdxLayoutGroup;
    EditEnd: TcxDateEdit;
    dxLayout1Item12: TdxLayoutItem;
    EditStart: TcxDateEdit;
    dxLayout1Item13: TdxLayoutItem;
    EditTrans: TcxComboBox;
    dxLayout1Item11: TdxLayoutItem;
    procedure BtnOKClick(Sender: TObject);
  protected
    { Protected declarations }
    FTruckID: string;
    procedure LoadFormData(const nID: string);
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl, UDataModule, UFormCtrl, USysDB, USysConst, UAdjustForm;

class function TfFormTruck.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
       nP := nParam
  else Exit;

  with TfFormTruck.Create(Application) do
  try
    if nP.FCommand = cCmd_AddData then
    begin
      Caption := '车辆 - 添加';
      FTruckID := '';
    end;

    if nP.FCommand = cCmd_EditData then
    begin
      Caption := '车辆 - 修改';
      FTruckID := nP.FParamA;
    end;

    LoadFormData(FTruckID);
    nP.FCommand := cCmd_ModalResult;
    nP.FParamA := ShowModal;
  finally
    AdjustStringsItem(EditTrans.Properties.Items, True);
    Free;
  end;
end;

class function TfFormTruck.FormID: integer;
begin
  Result := cFI_FormTrucks;
end;

procedure TfFormTruck.LoadFormData(const nID: string);
var nStr: string;
    nEx: TDynamicStrArray;
begin
  SetLength(nEx, 1);
  nStr := 'P_ID=Select P_ID,P_Name From %s Order By P_ID ASC';
  nStr := Format(nStr, [sTable_Provider]);

  nEx[0] := 'P_ID';
  FDM.FillStringsData(EditTrans.Properties.Items, nStr, 0, '', nEx);
  AdjustCXComboBoxItem(EditTrans, False);

  if nID <> '' then
  begin
    nStr := 'Select * From %s Where R_ID=%s';
    nStr := Format(nStr, [sTable_Truck, nID]);
    FDM.QueryTemp(nStr);
  end;

  with FDM.SqlTemp do
  begin
    if (nID = '') or (RecordCount < 1) then
    begin
      CheckVerify.Checked := True;
      CheckValid.Checked := True;

      EditStart.Date := Now;
      EditEnd.Date := Now;
      Exit;
    end;

    EditTruck.Text := FieldByName('T_Truck').AsString;
    EditOwner.Text := FieldByName('T_Owner').AsString;
    EditPhone.Text := FieldByName('T_Phone').AsString;

    EditTrans.Text := FieldByName('T_MateName').AsString;
    EditStart.Date := FieldByName('T_StartTime').AsDateTime;
    EditEnd.Date   := FieldByName('T_EndTime').AsDateTime;

    CheckVerify.Checked := FieldByName('T_NoVerify').AsString = sFlag_No;
    CheckValid.Checked := FieldByName('T_Valid').AsString = sFlag_Yes;
    CheckUserP.Checked := FieldByName('T_PrePUse').AsString = sFlag_Yes;

    CheckVip.Checked   := True;
    CheckGPS.Checked   := FieldByName('T_HasGPS').AsString = sFlag_Yes;
  end;
end;

//Desc: 保存
procedure TfFormTruck.BtnOKClick(Sender: TObject);
var nStr,nTruck,nU,nV,nP,nVip,nGps,nEvent: string;
begin
  nTruck := UpperCase(Trim(EditTruck.Text));
  if nTruck = '' then
  begin
    ActiveControl := EditTruck;
    ShowMsg('请输入车牌号码', sHint);
    Exit;
  end;

  if EditStart.Date > EditEnd.Date then
  begin
    ActiveControl := EditEnd;
    ShowMsg('结束时间应大于开始时间', sHint);
    Exit;
  end;  

  if CheckValid.Checked then
       nV := sFlag_Yes
  else nV := sFlag_No;

  if CheckVerify.Checked then
       nU := sFlag_No
  else nU := sFlag_Yes;

  if CheckUserP.Checked then
       nP := sFlag_Yes
  else nP := sFlag_No;

  if CheckVip.Checked then
       nVip:=sFlag_TypeVIP
  else nVip:=sFlag_TypeCommon;

  if CheckGPS.Checked then
       nGps := sFlag_Yes
  else nGps := sFlag_No;

  if FTruckID = '' then
       nStr := ''
  else nStr := SF('R_ID', FTruckID, sfVal);

  if FTruckID='' then
  begin
    nStr := 'Select * From %s Where T_Truck=''%s''';
    nStr := Format(nStr, [sTable_Truck, nTruck]);

    if FDM.QueryTemp(nStr).RecordCount>0 then
    begin
      nStr := Format('车辆[%s]已存在', [nTruck]);
      ShowMsg(nStr, sHint);
      Exit;
    end;
  end;

  nStr := MakeSQLByStr([SF('T_Truck', nTruck),
          SF('T_Owner', EditOwner.Text),
          SF('T_Phone', EditPhone.Text),
          SF('T_MateName', EditTrans.Text),
          SF('T_NoVerify', nU),
          SF('T_Valid', nV),
          SF('T_PrePUse', nP),
          SF('T_VIPTruck', nVip),
          SF('T_HasGPS', nGps),
          SF('T_StartTime', Date2Str(EditStart.Date)),
          SF('T_EndTime', Date2Str(EditEnd.Date)),
          SF('T_LastTime', sField_SQLServer_Now, sfVal)
          ], sTable_Truck, nStr, FTruckID = '');
  FDM.ExecuteSQL(nStr);

  if FTruckID='' then
        nEvent := '添加[ %s ]档案信息.'
  else  nEvent := '修改[ %s ]档案信息.';
  nEvent := Format(nEvent, [nTruck]);
  FDM.WriteSysLog(sFlag_CommonItem, nTruck, nEvent); 

  ModalResult := mrOk;
  ShowMsg('车辆信息保存成功', sHint);
end;

initialization
  gControlManager.RegCtrl(TfFormTruck, TfFormTruck.FormID);
end.
