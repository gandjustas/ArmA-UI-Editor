﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Markup;
using System.Xaml;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Media;

namespace ArmA_UI_Editor.Code.Markup
{
    public class BindColor : BindConfig
    {
        public BindColor() { }

        public override object ProvideValue(IServiceProvider serviceProvider)
        {
            if (CurrentConfig == null)
                return Color.FromRgb(255, 0, 0);
            var data = CurrentConfig.ReceiveFieldFromHirarchy(CurrentClassPath, this.Path);
            if (data == null)
                throw new Exception(string.Format("Cannot locate field '{0}'", this.Path));
            var array = data.Array_Number;
            return Color.FromArgb((byte)(array[0] * 255), (byte)(array[1] * 255), (byte)(array[2] * 255), (byte)(array[3] * 255));
        }
    }
}
