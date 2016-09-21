inherited fFormHYReader: TfFormHYReader
  Left = 586
  Top = 381
  ClientHeight = 177
  ClientWidth = 375
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 375
    Height = 177
    inherited BtnOK: TButton
      Left = 229
      Top = 144
      TabOrder = 5
    end
    inherited BtnExit: TButton
      Left = 299
      Top = 144
      TabOrder = 6
    end
    object EditID: TcxTextEdit [2]
      Left = 93
      Top = 36
      ParentFont = False
      Properties.MaxLength = 15
      TabOrder = 0
      Width = 116
    end
    object EditName: TcxTextEdit [3]
      Left = 93
      Top = 61
      ParentFont = False
      Properties.MaxLength = 100
      TabOrder = 1
      Width = 125
    end
    object EditHost: TcxTextEdit [4]
      Left = 93
      Top = 86
      ParentFont = False
      TabOrder = 2
      Width = 121
    end
    object EditPort: TcxTextEdit [5]
      Left = 231
      Top = 86
      TabOrder = 3
      Text = '8000'
      Width = 121
    end
    object EditMemo: TcxTextEdit [6]
      Left = 93
      Top = 111
      TabOrder = 4
      Width = 121
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        object dxLayout1Item9: TdxLayoutItem
          AutoAligns = [aaVertical]
          AlignHorz = ahClient
          Caption = #35835#21345#22120#32534#21495':'
          Control = EditID
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Group3: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          ShowBorder = False
          object dxLayout1Item5: TdxLayoutItem
            AutoAligns = [aaVertical]
            AlignHorz = ahClient
            Caption = #35835#21345#22120#21517#31216':'
            Control = EditName
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Group2: TdxLayoutGroup
            ShowCaption = False
            Hidden = True
            LayoutDirection = ldHorizontal
            ShowBorder = False
            object dxLayout1Item3: TdxLayoutItem
              AutoAligns = [aaVertical]
              AlignHorz = ahClient
              Caption = 'IP  '#22320#22336':'
              Control = EditHost
              ControlOptions.ShowBorder = False
            end
            object dxLayout1Item4: TdxLayoutItem
              Caption = 'IP'#31471#21475':'
              Control = EditPort
              ControlOptions.ShowBorder = False
            end
          end
        end
        object dxLayout1Item6: TdxLayoutItem
          Caption = #22791'    '#27880':'
          Control = EditMemo
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
