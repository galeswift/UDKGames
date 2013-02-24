//------------------------------------------------------------------------------
// Base class for a collection of variables that define how to draw a specific
// state of a GUIVisualComponent. Create each collection as subobject in the
// MenuScene.
//
// Also provides the logic for HSV color manipulation, since it's much easier
// to interpolate the Hues of a HSV color than a RGB color.
//------------------------------------------------------------------------------
class GUIInfo extends Object
    abstract
    editinlinenew
    collapsecategories
    hidecategories(Object);

/**
 * Color represented by the four components Hue, Saturation, Value, and Alpha.
 * H must be between 0 and 360 (degrees).
 * S must be between 0 and 1.
 * V and A are normally between 0 and 1, but may exceed that range to give bloom.
 */
struct HSVColor
{
	var() float H, S, V, A;

	structdefaultproperties
	{
		A=1.0
	}
};


event InitializeInfo();
event DeleteInfo();

// Lerp between two values in the 255 range based on Alpha.
final function byte BLerp(byte A, byte B, float Alpha)
{
    return FloatToByte(Lerp(ByteToFloat(A), ByteToFloat(B), Alpha));
}


/**
 * Converts an RGB color to an HSV color, according to the algorithm described at http://en.wikipedia.org/wiki/HSL_and_HSV
 *
 * @param RGB the color to convert.
 * @return the HSV representation of the color.
 */
static final function HSVColor RGBToHSV(const out LinearColor RGB)
{
	local float Max;
	local float Min;
	local float Chroma;
	local HSVColor HSV;

	Min = FMin(FMin(RGB.R, RGB.G), RGB.B);
	Max = FMax(FMax(RGB.R, RGB.G), RGB.B);
	Chroma = Max - Min;

	// If Chroma is 0, then S is 0 by definition, and H is undefined but 0 by convention.
	if(Chroma != 0)
	{
		if(RGB.R == Max)
		{
			HSV.H = (RGB.G - RGB.B) / Chroma;

			if(HSV.H < 0.0)
			{
				HSV.H += 6.0;
			}
		}
		else if(RGB.G == Max)
		{
			HSV.H = ((RGB.B - RGB.R) / Chroma) + 2.0;
		}
		else //RGB.B == Max
		{
			HSV.H = ((RGB.R - RGB.G) / Chroma) + 4.0;
		}

		HSV.H *= 60.0;
		HSV.S = Chroma / Max;
	}

	HSV.V = Max;
	HSV.A = RGB.A;

	return HSV;
}


/**
 * Converts an HSV color to an RGB color, according to the algorithm described at http://en.wikipedia.org/wiki/HSL_and_HSV
 *
 * @param HSV the color to convert.
 * @return the RGB representation of the color.
 */
static final function LinearColor HSVToRGB(const out HSVColor HSV)
{
	local float Min;
	local float Chroma;
	local float Hdash;
	local float X;
	local LinearColor RGB;

	Chroma = HSV.S * HSV.V;
	Hdash = HSV.H / 60.0;
	X = Chroma * (1.0 - Abs((Hdash % 2.0) - 1.0));

	if(Hdash < 1.0)
	{
		RGB.R = Chroma;
		RGB.G = X;
	}
	else if(Hdash < 2.0)
	{
		RGB.R = X;
		RGB.G = Chroma;
	}
	else if(Hdash < 3.0)
	{
		RGB.G = Chroma;
		RGB.B = X;
	}
	else if(Hdash < 4.0)
	{
		RGB.G= X;
		RGB.B = Chroma;
	}
	else if(Hdash < 5.0)
	{
		RGB.R = X;
		RGB.B = Chroma;
	}
	else if(Hdash <= 6.0)
	{
		RGB.R = Chroma;
		RGB.B = X;
	}

	Min = HSV.V - Chroma;

	RGB.R += Min;
	RGB.G += Min;
	RGB.B += Min;
	RGB.A = HSV.A;

	return RGB;
}

DefaultProperties
{

}