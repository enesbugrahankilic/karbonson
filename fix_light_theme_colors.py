#!/usr/bin/env python3
"""
Açık temada okunabilir metin renkleri için Colors.white kullanımlarını düzelt.
Bu betik gradyen/renkli arka planları olan sayfaları hedef alır.
"""

import os
import re

def fix_file(file_path):
    """Dosyayı oku ve renk sorunlarını düzelt"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original = content
        
        # Yalnızca gradyen veya renk arka planı olan dosyaları işle
        if "LinearGradient" not in content and "gradient:" not in content:
            return False
        
        # foregroundColor: Colors.white -> ThemeColors.getTextOnColoredBackground
        content = re.sub(
            r'foregroundColor:\s*Colors\.white\b',
            'foregroundColor: ThemeColors.getTextOnColoredBackground(context)',
            content
        )
        
        # Metin "style: TextStyle(color: Colors.white" içinde
        content = re.sub(
            r'(style:\s*TextStyle\([^)]*?color:\s*)Colors\.white\b',
            r'\1ThemeColors.getTextOnColoredBackground(context)',
            content
        )
        
        # Icon rengi Colors.white - gradyen bölümünde
        # Bu daha dikkatli yapılmalı - sadece gradyen sections'da
        lines = content.split('\n')
        new_lines = []
        in_gradient_section = False
        
        for line in lines:
            # Gradyen bölümü başlangıcı
            if 'LinearGradient' in line or ('gradient:' in line):
                in_gradient_section = True
            
            # Gradyen bölümü sonu (kapalı parantez)
            if in_gradient_section and re.search(r'\s*\),?\s*$', line):
                # Kontrol: bu satır gradyen'in sonu mu?
                indent = len(line) - len(line.lstrip())
                if indent < 20:  # Gradyen bölümü genellikle az indent'li
                    # Sonraki satırlarda gradyen denetimini yapacağız
                    pass
            
            # Gradient ile ilgili bölümlerde Colors.white'ı değiştir
            if in_gradient_section:
                # Icon rengi
                line = re.sub(
                    r'color:\s*Colors\.white\b(?!\s*\.\s*withValues)',
                    'color: ThemeColors.getTextOnColoredBackground(context)',
                    line
                )
                # Text style rengi
                line = re.sub(
                    r'color:\s*Colors\.white\b',
                    'color: ThemeColors.getTextOnColoredBackground(context)',
                    line
                )
            
            new_lines.append(line)
        
        content = '\n'.join(new_lines)
        
        if content != original:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            return True
        return False
        
    except Exception as e:
        print(f"Hata {file_path}: {e}")
        return False

def main():
    """Ana fonksiyon - tüm Dart dosyalarını işle"""
    
    pages_dir = '/Users/omer/karbonson/lib/pages'
    widgets_dir = '/Users/omer/karbonson/lib/widgets'
    
    fixed_count = 0
    
    # Sayfaları işle
    if os.path.exists(pages_dir):
        for filename in os.listdir(pages_dir):
            if filename.endswith('.dart'):
                file_path = os.path.join(pages_dir, filename)
                if fix_file(file_path):
                    print(f"✓ Düzeltildi: {filename}")
                    fixed_count += 1
    
    # Widget'ları işle
    if os.path.exists(widgets_dir):
        for filename in os.listdir(widgets_dir):
            if filename.endswith('.dart'):
                file_path = os.path.join(widgets_dir, filename)
                if fix_file(file_path):
                    print(f"✓ Düzeltildi: lib/widgets/{filename}")
                    fixed_count += 1
            else:
                # Alt dizinleri işle
                subdir = os.path.join(widgets_dir, filename)
                if os.path.isdir(subdir):
                    for subfile in os.listdir(subdir):
                        if subfile.endswith('.dart'):
                            file_path = os.path.join(subdir, subfile)
                            if fix_file(file_path):
                                print(f"✓ Düzeltildi: lib/widgets/{filename}/{subfile}")
                                fixed_count += 1
    
    print(f"\n✅ Toplam {fixed_count} dosya düzeltildi!")

if __name__ == '__main__':
    main()
