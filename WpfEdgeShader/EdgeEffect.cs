using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Media;
using System.Windows.Media.Effects;

namespace WpfShader01
{
    public class EdgeEffect : ShaderEffect
    {
        private static PixelShader _pixelShader =
            new PixelShader() { UriSource = MakePackUri("EdgeEffect.fx.ps") };

        public EdgeEffect()
        {
            PixelShader = _pixelShader;

            UpdateShaderValue(InputProperty);
            UpdateShaderValue(ImageWidthProperty);
            UpdateShaderValue(ImageHeightProperty);
            UpdateShaderValue(ThresholdProperty);
        }

        // MakePackUri is a utility method for computing a pack uri
        // for the given resource. 
        public static Uri MakePackUri(string relativeFile)
        {
            Assembly a = typeof(ThresholdEffect).Assembly;

            // Extract the short name.
            string assemblyShortName = a.ToString().Split(',')[0];

            string uriString = "pack://application:,,,/" +
                assemblyShortName +
                ";component/" +
                relativeFile;

            return new Uri(uriString);
        }

        #region Input dependency property

        public Brush Input
        {
            get { return (Brush)GetValue(InputProperty); }
            set { SetValue(InputProperty, value); }
        }

        public static readonly DependencyProperty InputProperty =
            ShaderEffect.RegisterPixelShaderSamplerProperty("Input", typeof(EdgeEffect), 0);

        #endregion

        
        #region ImageWidth dependency property

        public float ImageWidth
        {
            get => (float)GetValue(ImageWidthProperty);
            set => SetValue(ImageWidthProperty, value);
        }

        public static readonly DependencyProperty ImageWidthProperty = DependencyProperty.Register(nameof(ImageWidth),
            typeof(float),
            typeof(EdgeEffect),
            new UIPropertyMetadata(0.0f,
                PixelShaderConstantCallback(0)));
        #endregion

        #region ImageHeight dependency property

        public float ImageHeight
        {
            get => (float) GetValue(ImageHeightProperty);
            set => SetValue(ImageHeightProperty, value);
        }

        public static readonly DependencyProperty ImageHeightProperty = DependencyProperty.Register(nameof(ImageHeight),
            typeof(float),
            typeof(EdgeEffect),
            new UIPropertyMetadata(0.0f,
                PixelShaderConstantCallback(1)));

        #endregion


        #region Threshold dependency property

        public float Threshold
        {
            get { return (float)GetValue(ThresholdProperty); }
            set { SetValue(ThresholdProperty, value); }
        }

        public static readonly DependencyProperty ThresholdProperty =
            DependencyProperty.Register("Threshold", typeof(float), typeof(EdgeEffect),
                    new UIPropertyMetadata(0.5f, PixelShaderConstantCallback(2)));

        #endregion
    }
}
