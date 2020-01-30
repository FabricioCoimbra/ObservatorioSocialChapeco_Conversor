object DM: TDM
  OldCreateOrder = False
  Height = 150
  Width = 215
  object OpenDialog: TOpenDialog
    Filter = 'txt|*.txt'
    Title = 'Selecionar arquivo de texto .txt'
    Left = 24
    Top = 14
  end
  object SaveDialog: TSaveDialog
    Filter = 'csv|*.csv'
    Left = 119
    Top = 14
  end
  object OpenIMG: TOpenDialog
    DefaultExt = '*.jpg;*.jpeg;*.psd;*.tga*.png;*.gif;*.bmp'
    Filter = 'Arquivos de Imagem|*.jpg;*.jpeg;*.psd;*.tga;*.png;*.gif;*.bmp'
    Title = 'Selecionar imagem'
    Left = 32
    Top = 78
  end
end
