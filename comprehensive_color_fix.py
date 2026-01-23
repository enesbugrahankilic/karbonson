#!/usr/bin/env python3
"""
Tüm Colors.white ve Colors.black sabit kullanımlarını tema-uyumlu versiyonlarla değiştir.
Bu script özel bağlamları göz önüne alır.
"""

import os
import re

def smart_replace_colors(content):
    """Akıllı renk değiştirme"""
    
    # 1. Icon renkleri - Colors.white
    content = re.sub(
        r'(\bicon:\s*(?:const\s+)?Icon\([^)]*?color:\s*)Colors\.white\b',
        r'\1ThemeColors.getTextOnColoredBackground(context)',
        content
    )
    
    # 2. TextStyle içindeki color - Colors.white
    content = re.sub(
        r'(style:\s*TextStyle\([^)]*?color:\s*)Colors\.white\b',
        r'\1ThemeColors.getTextOnColoredBackground(context)',
        content
    )
    
    # 3. Düğme metni (foregroundColor) - Colors.white
    # ANCAK: ElevatedButton style içindeki foregroundColor genellikle tema değişmez
    # Yalnızca gradient bölümleri içinde değiştir
    content = re.sub(
        r'(foregroundColor:\s*)Colors\.white(?=\s*,\s*backgroundColor:\s*(?:ThemeColors\.|Colors\.)(?:getPrimary|getSuccess|getWarning|getError|getInfo|getPrimaryButton|getAccent|red|green|orange|blue|purple))',
        r'\1ThemeColors.getTextOnColoredBackground(context)',
        content
    )
    
    # 4. Text widget'ındaki color - Colors.white
    content = re.sub(
        r'(\bText\([^)]*?style:\s*TextStyle\([^)]*?color:\s*)Colors\.white\b',
        r'\1ThemeColors.getTextOnColoredBackground(context)',
        content
    )
    
    # 5. Custom color kullanımları - Colors.white.withValues
    # Gradient bölümleri içinde
    content = re.sub(
        r'(gradient:\s*LinearGradient\([^)]*?colors:\s*\[.*?color:\s*)Colors\.white\.withValues',
        r'\1ThemeColors.getTextOnColoredBackground(context).withValues',
        content,
        flags=re.DOTALL
    )
    
    # 6. Border color - Colors.white
    content = re.sub(
        r'(border:\s*Border\.all\([^)]*?color:\s*)Colors\.white\b',
        r'\1ThemeColors.getTextOnColoredBackground(context)',
        content
    )
    
    return content

def process_file(file_path):
    """Dosyayı işle"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            original_content = f.read()
        
        content = original_content
        
        # İçeriği düzenle
        content = smart_replace_colors(content)
        
        # Kaydederse
        if content != original_content:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            return True
        
        return False
    
    except Exception as e:
        print(f"Hata {file_path}: {e}")
        return False

def main():
    """Tüm dosyaları işle"""
    pages_dir = '/Users/omer/karbonson/lib/pages'
    widgets_dir = '/Users/omer/karbonson/lib/widgets'
    
    fixed_count = 0
    
    # Tüm Dart dosyalarını bul ve işle
    all_dirs = []
    if os.path.exists(pages_dir):
        all_dirs.append(pages_dir)
    if os.path.exists(widgets_dir):
        all_dirs.append(widgets_dir)
        # Alt dizinleri de ekle
        for item in os.listdir(widgets_dir):
            subdir = os.path.join(widgets_dir, item)
            if os.path.isdir(subdir):
                all_dirs.append(subdir)
    
    for directory in all_dirs:
        for filename in os.listdir(directory):
            if filename.endswith('.dart'):
                file_path = os.path.join(directory, filename)
                if process_file(file_path):
                    rel_path = os.path.relpath(file_path, '/Users/omer/karbonson')
                    print(f"✓ Düzeltildi: {rel_path}")
                    fixed_count += 1
    
    print(f"\n✅ Toplam {fixed_count} dosya güncellendi!")

if __name__ == '__main__':
    main()
