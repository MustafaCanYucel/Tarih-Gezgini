#!/bin/bash

echo "🎮 Tarih Gezgini - Android APK Oluşturucu"
echo "=========================================="
echo ""

# Renk kodları
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Cordova kontrolü
if ! command -v cordova &> /dev/null; then
    echo -e "${RED}❌ Cordova yüklü değil!${NC}"
    echo "Yüklemek için: sudo npm install -g cordova"
    exit 1
fi

echo -e "${GREEN}✅ Cordova bulundu${NC}"

# Proje klasörünü temizle
if [ -d "tarih-gezgini-mobile" ]; then
    echo -e "${YELLOW}⚠️  Eski proje bulundu, siliniyor...${NC}"
    rm -rf tarih-gezgini-mobile
fi

# Yeni Cordova projesi oluştur
echo "📦 Cordova projesi oluşturuluyor..."
cordova create tarih-gezgini-mobile com.tarihgezgini.app "Tarih Gezgini" --template blank

cd tarih-gezgini-mobile

# Android platformu ekle
echo "🤖 Android platformu ekleniyor..."
cordova platform add android

# Plugin'leri ekle
echo "🔌 Plugin'ler ekleniyor..."
cordova plugin add cordova-plugin-device
cordova plugin add cordova-plugin-statusbar
cordova plugin add cordova-plugin-splashscreen
cordova plugin add cordova-plugin-media

# www klasörünü temizle
echo "🗑️  www klasörü temizleniyor..."
rm -rf www/*

# Oyun dosyalarını kopyala
echo "📁 Oyun dosyaları kopyalanıyor..."
cp "../tarih-gezgini-final kopyası.html" www/index.html

# assets klasörünü kopyala
if [ -d "../assets" ]; then
    cp -r ../assets www/
    echo -e "${GREEN}✅ Assets kopyalandı${NC}"
else
    echo -e "${YELLOW}⚠️  assets klasörü bulunamadı${NC}"
fi

# index.html'i düzenle (Cordova için)
echo "⚙️  index.html düzenleniyor..."

# Cordova script'ini ekle
cat > www/cordova-init.js << 'EOF'
document.addEventListener('deviceready', function() {
    console.log('Cordova is ready!');
    // StatusBar ayarları
    if (window.StatusBar) {
        StatusBar.hide();
    }
    // Ekran yönlendirme
    if (window.screen && window.screen.orientation) {
        screen.orientation.lock('landscape').catch(function(error) {
            console.log('Orientation lock failed:', error);
        });
    }
}, false);
EOF

# index.html'e Cordova script'lerini ekle
sed -i '' 's|</body>|<script src="cordova.js"></script>\n<script src="cordova-init.js"></script>\n</body>|' www/index.html

# Viewport meta tag ekle
sed -i '' 's|<head>|<head>\n<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">\n<meta name="format-detection" content="telephone=no">|' www/index.html

# config.xml'i güncelle
echo "📝 config.xml düzenleniyor..."
cat > config.xml << 'EOF'
<?xml version='1.0' encoding='utf-8'?>
<widget id="com.tarihgezgini.app" version="1.0.0" xmlns="http://www.w3.org/ns/widgets">
    <name>Tarih Gezgini</name>
    <description>
        Türkiye'nin tarihi bölgelerinde koşarak sorulara cevap verin!
    </description>
    <author email="info@tarihgezgini.com">
        Tarih Gezgini Ekibi
    </author>
    <content src="index.html" />
    
    <preference name="Orientation" value="landscape" />
    <preference name="Fullscreen" value="true" />
    <preference name="DisallowOverscroll" value="true" />
    <preference name="BackgroundColor" value="0xff87CEEB" />
    <preference name="SplashScreenDelay" value="2000" />
    <preference name="AutoHideSplashScreen" value="true" />
    <preference name="KeepRunning" value="true"/>
    
    <platform name="android">
        <preference name="android-minSdkVersion" value="24" />
        <preference name="android-targetSdkVersion" value="33" />
        <allow-intent href="market:*" />
    </platform>
    
    <access origin="*" />
    <allow-intent href="http://*/*" />
    <allow-intent href="https://*/*" />
    <allow-navigation href="*" />
</widget>
EOF

# APK oluştur
echo ""
echo "🔨 APK oluşturuluyor..."
echo "Bu işlem birkaç dakika sürebilir..."
cordova build android

# Sonuç
if [ -f "platforms/android/app/build/outputs/apk/debug/app-debug.apk" ]; then
    echo ""
    echo -e "${GREEN}=========================================="
    echo "✅ APK BAŞARIYLA OLUŞTURULDU!"
    echo "==========================================${NC}"
    echo ""
    echo "📱 APK Konumu:"
    echo "   $(pwd)/platforms/android/app/build/outputs/apk/debug/app-debug.apk"
    echo ""
    echo "📊 APK Boyutu:"
    ls -lh platforms/android/app/build/outputs/apk/debug/app-debug.apk | awk '{print "   " $5}'
    echo ""
    echo "🚀 Test için:"
    echo "   adb install platforms/android/app/build/outputs/apk/debug/app-debug.apk"
    echo ""
    echo "📦 APK'yı masaüstüne kopyalamak için:"
    echo "   cp platforms/android/app/build/outputs/apk/debug/app-debug.apk ~/Desktop/TarihGezgini.apk"
    echo ""
else
    echo -e "${RED}❌ APK oluşturulamadı!${NC}"
    echo "Hata loglarını kontrol edin."
    exit 1
fi
