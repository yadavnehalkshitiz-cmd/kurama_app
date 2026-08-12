from hashlib import sha256
from pathlib import Path
import unittest


ROOT = Path(__file__).parents[1]
OLD_FLUTTER_ICON_HASHES = {
    "6A7C8F0D703E3682108F9662F813302236240D3F8F638BB391E32BFB96055FEF",
    "C7C0C0189145E4E32A401C61C9BDC615754B0264E7AFAE24E834BB81049EAF81",
    "E14AA40904929BF313FDED22CF7E7FFCBF1D1AAC4263B5EF1BE8BFCE650397AA",
    "4D470BF22D5C17D84EDC5F82516D1BA8A1C09559CD761CEFB792F86D9F52B540",
    "3C34E1F298D0C9EA3455D46DB6B7759C8211A49E9EC6E44B635FC5C87DFB4180",
}


class BrandingTests(unittest.TestCase):
    def test_master_logo_is_the_approved_asset(self):
        logo = ROOT / "mobile/assets/images/logo.png"
        self.assertEqual(
            "57226B60FEF610C43D041DD2981D33F5AE85FB33C864108FAD9C44EBE3DD6CB8",
            sha256(logo.read_bytes()).hexdigest().upper(),
        )

    def test_generated_icons_are_not_flutter_defaults(self):
        icons = sorted(
            (ROOT / "mobile/android/app/src/main/res").glob(
                "mipmap-*/ic_launcher.png"
            )
        )
        self.assertGreaterEqual(len(icons), 5)
        for icon in icons:
            with self.subTest(icon=icon.name):
                digest = sha256(icon.read_bytes()).hexdigest().upper()
                self.assertNotIn(digest, OLD_FLUTTER_ICON_HASHES)

    def test_adaptive_icon_resource_exists(self):
        adaptive = (
            ROOT
            / "mobile/android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml"
        )
        self.assertTrue(adaptive.is_file())


if __name__ == "__main__":
    unittest.main()
