inherited fFrameTruckLogQuery: TfFrameTruckLogQuery
  Width = 976
  Height = 582
  inherited ToolBar1: TToolBar
    Width = 976
    inherited BtnAdd: TToolButton
      Visible = False
    end
    inherited BtnEdit: TToolButton
      Visible = False
    end
    inherited BtnDel: TToolButton
      Visible = False
    end
    inherited S1: TToolButton
      Visible = False
    end
  end
  inherited cxGrid1: TcxGrid
    Top = 205
    Width = 976
    Height = 377
    inherited cxView1: TcxGridDBTableView
      PopupMenu = PMenu1
    end
  end
  inherited dxLayout1: TdxLayoutControl
    Width = 976
    Height = 138
    object cxTextEdit1: TcxTextEdit [0]
      Left = 81
      Top = 93
      Hint = 'T.T_Truck'
      ParentFont = False
      TabOrder = 2
      Width = 125
    end
    object EditTruck: TcxButtonEdit [1]
      Left = 81
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditTruckPropertiesButtonClick
      TabOrder = 0
      OnKeyPress = OnCtrlKeyPress
      Width = 125
    end
    object cxTextEdit3: TcxTextEdit [2]
      Left = 269
      Top = 93
      Hint = 'T.T_InTime'
      ParentFont = False
      TabOrder = 3
      Width = 125
    end
    object EditDate: TcxButtonEdit [3]
      Left = 269
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.ReadOnly = True
      Properties.OnButtonClick = EditDatePropertiesButtonClick
      TabOrder = 1
      Width = 185
    end
    object cxTextEdit4: TcxTextEdit [4]
      Left = 457
      Top = 93
      Hint = 'T.T_OutTime'
      ParentFont = False
      TabOrder = 4
      Width = 125
    end
    inherited dxGroup1: TdxLayoutGroup
      inherited GroupSearch1: TdxLayoutGroup
        object dxLayout1Item2: TdxLayoutItem
          Caption = #36710#29260#21495#30721':'
          Control = EditTruck
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item6: TdxLayoutItem
          Caption = #26085#26399#31579#36873':'
          Control = EditDate
          ControlOptions.ShowBorder = False
        end
      end
      inherited GroupDetail1: TdxLayoutGroup
        object dxLayout1Item1: TdxLayoutItem
          Caption = #36710#29260#21495#30721':'
          Control = cxTextEdit1
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item5: TdxLayoutItem
          Caption = #36827#21378#26102#38388':'
          Control = cxTextEdit3
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item7: TdxLayoutItem
          Caption = #20986#21378#26102#38388':'
          Control = cxTextEdit4
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
  inherited cxSplitter1: TcxSplitter
    Top = 197
    Width = 976
  end
  inherited TitlePanel1: TZnBitmapPanel
    Width = 976
    inherited TitleBar: TcxLabel
      Caption = #36710#36742#36890#23703#35760#24405#26597#35810
      Style.IsFontAssigned = True
      Width = 976
      AnchorX = 488
      AnchorY = 11
    end
  end
  inherited SQLQuery: TADOQuery
    Left = 2
    Top = 234
  end
  inherited DataSource1: TDataSource
    Left = 30
    Top = 234
  end
  object PMenu1: TPopupMenu
    AutoHotkeys = maManual
    Left = 2
    Top = 262
    object N4: TMenuItem
      Caption = #36807#23703#26102#25235#25293
      OnClick = N4Click
    end
    object N5: TMenuItem
      Caption = '-'
    end
    object N8: TMenuItem
      Caption = #8251#26102#38388#26597#35810#8251
      Enabled = False
    end
    object N2: TMenuItem
      Tag = 30
      Caption = #26102#38388#27573#26597#35810
      OnClick = N2Click
    end
  end
end
