#!/usr/bin/env python3
"""
Accessories Master Catalog generator — Baba Farid Mobiles (Pakpattan, Punjab).

Builds the catalog from matrices (categories, brands, device models,
variants) and writes BOTH:
  - database/catalog/accessories_catalog.json
  - database/migrations/001_accessories_catalog.sql

Usage:
    python3 scripts/generate_catalog.py [--out-dir <project root>]
    python3 scripts/generate_catalog.py --check   # validate outputs only

PRICES ARE ESTIMATES.
Every record carries "estimated": true. Prices are sensible Punjab-market
estimates in whole PKR at the time of generation — NOT live market rates.
The shopkeeper confirms the real buying price at stock-in, and a catalog
version update only ever refreshes *estimated* prices; it never overwrites
stock, shopkeeper-set prices, or custom items (see docs/catalog.md).

To add categories / items: edit the matrices in this file and re-run.
Do NOT hand-edit the generated JSON or SQL.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from collections import Counter, defaultdict
from datetime import datetime, timezone
from pathlib import Path

VERSION = "1.0.0"
PROJECT_ROOT = Path(__file__).resolve().parent.parent

# ---------------------------------------------------------------------------
# Categories
# ---------------------------------------------------------------------------
# (code, name_en, name_ur, sort_order)
CATEGORIES = [
    ("Chargers", "Chargers", "چارجر", 1),
    ("Cables", "Cables", "کیبل", 2),
    ("Power Banks", "Power Banks", "پاور بینک", 3),
    ("Audio", "Handsfree & Audio", "ہینڈزفری اور آڈیو", 4),
    ("Protection", "Protection", "پروٹیکشن", 5),
    ("Holders", "Phone Holders", "فون ہولڈر", 6),
    ("Memory", "Memory & Storage", "میموری اور اسٹوریج", 7),
    ("Smart Accessories", "Smart Accessories", "اسمارٹ ایکسیسریز", 8),
    ("Repair Parts", "Repair Parts", "ریپیئر پارٹس", 9),
    ("Others", "Others", "دیگر", 10),
]
CAT_CODE = {
    "Chargers": "CHG", "Cables": "CAB", "Power Banks": "PWB",
    "Audio": "AUD", "Protection": "PRT", "Holders": "HLD",
    "Memory": "MEM", "Smart Accessories": "SMA",
    "Repair Parts": "RPR", "Others": "OTH",
}

# ---------------------------------------------------------------------------
# Brands  (name -> 3-letter SKU code)
# ---------------------------------------------------------------------------
BRANDS = {
    "Anker": "ANK", "Baseus": "BAS", "Ugreen": "UGR", "Remax": "RMX",
    "Hoco": "HOC", "Xiaomi": "XIA", "Oraimo": "ORA", "QCY": "QCY",
    "Realme": "RLM", "Samsung": "SAM", "Apple": "APL", "Infinix": "INF",
    "Tecno": "TEC", "Vivo": "VIV", "Oppo": "OPP", "Huawei": "HUA",
    "Faster": "FST", "Audionic": "AUD", "Ronin": "RON", "Space": "SPC",
    "Yison": "YIS", "JBL": "JBL", "SanDisk": "SDK", "Kingston": "KNG",
    "Generic": "GEN",
}

# ---------------------------------------------------------------------------
# Urdu translation map (English phrase -> Urdu). Used to compose name_ur
# from name_en. Brand names, model names and numbers stay in Latin script.
# Multi-word phrases are matched first (longest first).
# ---------------------------------------------------------------------------
URDU_MAP = {
    "power bank": "پاور بینک", "tempered glass": "ٹیمپرڈ گلاس",
    "back cover": "بیک کور", "handsfree": "ہینڈزفری",
    "charging port": "چارجنگ پورٹ", "charging cable": "چارجنگ کیبل",
    "car charger": "کار چارجر", "wall charger": "وال چارجر",
    "wireless charger": "وائرلیس چارجر", "fast charger": "فاسٹ چارجر",
    "multi port charger": "ملٹی پورٹ چارجر", "phone holder": "فون ہولڈر",
    "car holder": "کار ہولڈر", "selfie stick": "سیلفی اسٹک",
    "ring light": "رنگ لائٹ", "smart watch": "اسمارٹ گھڑی",
    "fitness band": "فٹنس بینڈ", "memory card": "میموری کارڈ",
    "flash drive": "فلیش ڈرائیو", "card reader": "کارڈ ریڈر",
    "camera lens protector": "کیمرہ لینز پروٹیکٹر",
    "pop socket": "پاپ ساکٹ", "screen protector": "اسکرین پروٹیکٹر",
    "charger": "چارجر", "cable": "کیبل", "earbuds": "ایئربڈز",
    "neckband": "نیک بینڈ", "headphones": "ہیڈ فون", "headphone": "ہیڈ فون",
    "speaker": "اسپیکر", "battery": "بیٹری", "watch": "گھڑی",
    "glass": "گلاس", "cover": "کور", "case": "کیس",
    "wireless": "وائرلیس", "bluetooth": "بلوٹوتھ", "fast": "فاسٹ",
    "silicone": "سلیکون", "leather": "چمڑا", "flip": "فلپ",
    "clear": "شفاف", "hard": "ہارڈ", "matte": "میٹ",
    "privacy": "پرائیویسی", "braided": "بریڈڈ", "nylon": "نائلون",
    "magnetic": "میگنیٹک", "solar": "سولر", "mini": "منی",
    "pro": "پرو", "max": "میکس", "ultra": "الٹرا",
    "adapter": "اڈاپٹر", "converter": "کنورٹر", "holder": "ہولڈر",
    "tripod": "ٹرائپوڈ", "gimbal": "جمبل", "stand": "اسٹینڈ",
    "mount": "ماؤنٹ", "dock": "ڈاک", "hub": "ہب",
    "keyboard": "کی بورڈ", "mouse": "ماؤس", "laptop": "لیپ ٹاپ",
    "gaming": "گیمنگ", "controller": "کنٹرولر", "trigger": "ٹرگر",
    "ejector pin": "ایکجیکٹر پن", "sim tray": "سم ٹرے",
    "tool kit": "ٹول کٹ", "screwdriver": "اسکریو ڈرائیور",
    "lcd": "ایل سی ڈی", "screen": "اسکرین", "display": "ڈسپلے",
    "speaker": "اسپیکر", "microphone": "مائیکروفون", "mic": "مائیک",
    "flex": "فلیکس", "back glass": "بیک گلاس",
    "otg": "او ٹی جی", "usb": "یو ایس بی", "type-c": "ٹائپ سی",
    "lightning": "لائٹننگ", "micro usb": "مائیکرو یو ایس بی",
    "strap": "اسٹراپ", "band": "بینڈ", "tracker": "ٹریکر",
    "earphone": "ایئرفون", "earphones": "ایئرفون",
    "airpods": "ایئرپوڈز", "buds": "بڈز",
    "data cable": "ڈیٹا کیبل", "audio": "آڈیو",
    "with mic": "مائیک کے ساتھ", "noise cancelling": "نائس کینسلنگ",
    "original": "اوریجنل", "premium": "پریمیم", "classic": "کلاسک",
    "protective": "حفاظتی", "shockproof": "شاک پروف",
    "transparent": "شفاف", "coloured": "رنگین", "color": "رنگ",
    "black": "کالا", "white": "سفید", "blue": "نیلا",
    "red": "سرخ", "gold": "سنہری", "pink": "گلابی",
    "green": "سبز", "purple": "جامنی", "silver": "چاندی",
    "portable": "پورٹیبل", "foldable": "فولڈ ایبل",
    "heavy duty": "ہیوی ڈیوٹی", "dual": "ڈوئل",
    "led": "ایل ای ڈی", "display": "ڈسپلے",
    "charging": "چارجنگ", "charge": "چارج",
}
_URDU_KEYS = sorted(URDU_MAP, key=len, reverse=True)


def to_urdu(name_en: str) -> str:
    """Compose an Urdu display name from the English name using URDU_MAP.

    Phrases are replaced longest-first; brand names, model names and
    numbers are left in Latin script (that is how shopkeepers write them).
    """
    lowered = name_en.lower()
    out = lowered
    for key in _URDU_KEYS:
        out = out.replace(key, URDU_MAP[key])
    # Title-case the leftover Latin words for a tidy display name.
    parts = []
    for word in out.split(" "):
        if re.search(r"[\u0600-\u06FF]", word):
            parts.append(word)
        elif word:
            parts.append(word[:1].upper() + word[1:])
    return " ".join(parts)


# ---------------------------------------------------------------------------
# Device models (for covers / glass / lens protectors / repair parts)
# (device_brand, device_model)
# ---------------------------------------------------------------------------
DEVICE_MODELS: list[tuple[str, str]] = []
for m in ["11", "11 Pro", "11 Pro Max", "12", "12 Mini", "12 Pro", "12 Pro Max",
          "13", "13 Mini", "13 Pro", "13 Pro Max", "14", "14 Plus", "14 Pro",
          "14 Pro Max", "15", "15 Plus", "15 Pro", "15 Pro Max", "16",
          "16 Plus", "16 Pro", "16 Pro Max"]:
    DEVICE_MODELS.append(("Apple", f"iPhone {m}"))
for m in ["A04", "A04s", "A05", "A05s", "A14", "A15", "A24", "A34", "A54",
          "A55", "M14", "M34", "M54", "S21", "S21 FE", "S22", "S22 Ultra",
          "S23", "S23 FE", "S23 Ultra", "S24", "S24 Ultra", "S24 FE",
          "Note 20", "Z Flip 5"]:
    DEVICE_MODELS.append(("Samsung", f"Galaxy {m}"))
for m in ["Hot 10", "Hot 11", "Hot 12", "Hot 30", "Hot 40", "Hot 40 Pro",
          "Note 10", "Note 12", "Note 30", "Note 40", "Smart 7", "Smart 8"]:
    DEVICE_MODELS.append(("Infinix", m))
for m in ["Spark 7", "Spark 8", "Spark 10", "Spark 20", "Camon 18",
          "Camon 19", "Camon 20", "Pova 4", "Pova 5", "Pova 6", "Pop 7",
          "Phantom X2"]:
    DEVICE_MODELS.append(("Tecno", m))
for m in ["Y02", "Y16", "Y17s", "Y21", "Y22", "Y27", "Y36", "V21", "V23",
          "V25", "V27", "V29", "V30"]:
    DEVICE_MODELS.append(("Vivo", m))
for m in ["A16", "A17", "A18", "A38", "A57", "A58", "A78", "Reno 6",
          "Reno 8", "Reno 11", "F21 Pro"]:
    DEVICE_MODELS.append(("Oppo", m))
for m in ["Redmi 9", "Redmi 10", "Redmi 12", "Redmi 13", "Redmi Note 10",
          "Redmi Note 11", "Redmi Note 12", "Redmi Note 13",
          "Redmi Note 13 Pro", "Mi 11", "Mi 12", "13 Lite", "Poco X3",
          "Poco X5", "Poco M5", "Poco F5"]:
    DEVICE_MODELS.append(("Xiaomi", m))
for m in ["C11", "C21", "C25", "C35", "C51", "C53", "Narzo 50", "9 Pro",
          "10 Pro", "11 Pro", "12", "GT Neo 3"]:
    DEVICE_MODELS.append(("Realme", m))
for m in ["Y6p", "Y7a", "Y9a", "Nova 9", "Nova 10", "P30", "P40", "Mate 20"]:
    DEVICE_MODELS.append(("Huawei", m))

# ---------------------------------------------------------------------------
# Catalog builder
# ---------------------------------------------------------------------------
items: list[dict] = []
_sku_counters: dict[str, int] = defaultdict(int)
_seen_skus: set[str] = set()
_model_links: list[dict] = []  # {sku, device_brand, device_model}


def _round10(n: float) -> int:
    return max(10, int(round(n / 10.0)) * 10)


def pricing(purchase: int, margin: float = 1.30) -> tuple[int, int, int]:
    """(purchase_price_est, sale_price_est, min_price) — whole PKR.

    sale = purchase * margin rounded to nearest 10; min = just above cost.
    """
    sale = _round10(purchase * margin)
    min_price = _round10(purchase * 1.05)
    return purchase, sale, min_price


def _sku_token(text: str) -> str:
    token = re.sub(r"[^A-Z0-9]", "", text.upper())
    return token[:6] or "GEN"


def add_item(*, category: str, brand: str, name_en: str, variant_token: str,
             purchase: int, margin: float = 1.30,
             model_compatibility: str | None = None,
             device: tuple[str, str] | None = None,
             colors: list[str] | None = None,
             variants: list[str] | None = None,
             unit: str = "piece", low_stock_threshold: int = 5) -> dict:
    """Append one catalog item. SKU: ACC-<CAT>-<BRAND>-<TOKEN>-<NNN>."""
    brand_code = BRANDS[brand]
    cat_code = CAT_CODE[category]
    token = _sku_token(variant_token)
    key = f"{cat_code}-{brand_code}-{token}"
    _sku_counters[key] += 1
    sku = f"ACC-{key}-{_sku_counters[key]:03d}"
    assert sku not in _seen_skus, f"duplicate SKU {sku}"
    _seen_skus.add(sku)
    p, s, mn = pricing(purchase, margin)
    item = {
        "sku": sku,
        "category": category,
        "brand": brand,
        "name_en": name_en,
        "name_ur": to_urdu(name_en),
        "model_compatibility": model_compatibility,
        "colors": colors or [],
        "variants": variants or [],
        "purchase_price_est": p,
        "sale_price_est": s,
        "min_price": mn,
        "unit": unit,
        "barcode": None,
        "is_custom": False,
        "estimated": True,
        "low_stock_threshold": low_stock_threshold,
    }
    items.append(item)
    if device is not None:
        _model_links.append({
            "sku": sku,
            "device_brand": device[0],
            "device_model": device[1],
        })
    return item


# ---------------------------------------------------------------------------
# 1. Chargers
# ---------------------------------------------------------------------------
def build_chargers() -> None:
    # Wall chargers: brand x wattage (only the wattages each brand sells).
    wall: dict[str, list[tuple[int, int]]] = {  # watt, purchase price
        "Anker": [(10, 900), (18, 1500), (20, 1800), (25, 2200), (33, 2800), (45, 3800), (65, 5500)],
        "Baseus": [(10, 700), (18, 1200), (20, 1500), (25, 1900), (33, 2400), (45, 3400), (65, 5000)],
        "Ugreen": [(18, 1300), (20, 1600), (25, 2000), (33, 2600), (45, 3600), (65, 5200)],
        "Remax": [(10, 500), (18, 900), (20, 1100), (25, 1400), (33, 1800)],
        "Hoco": [(10, 450), (18, 800), (20, 1000), (25, 1300), (33, 1700)],
        "Samsung": [(15, 1200), (25, 2200), (45, 4200)],
        "Xiaomi": [(18, 900), (20, 1100), (33, 1800), (65, 4500)],
        "Oraimo": [(10, 450), (18, 800), (20, 1000), (25, 1300)],
        "Faster": [(10, 400), (18, 750), (20, 950), (25, 1200), (33, 1600)],
        "Generic": [(10, 250), (18, 450), (20, 550), (25, 700), (33, 900)],
    }
    for brand, watts in wall.items():
        for watt, price in watts:
            add_item(category="Chargers", brand=brand,
                     name_en=f"{brand} {watt}W Fast Wall Charger",
                     variant_token=f"{watt}W", purchase=price,
                     colors=["White", "Black"],
                     variants=["USB-A", "USB-C"] if watt <= 25 else ["USB-C", "Dual Port"])
    # Car chargers.
    for brand in ["Anker", "Baseus", "Remax", "Hoco", "Faster", "Generic"]:
        for watt, price in [(18, 700), (25, 1000), (30, 1200), (45, 1800)]:
            add_item(category="Chargers", brand=brand,
                     name_en=f"{brand} {watt}W Car Charger Dual Port",
                     variant_token=f"CAR{watt}", purchase=price,
                     colors=["Black"], variants=["USB-A + USB-C"])
    # Wireless chargers.
    for brand, price in [("Anker", 2800), ("Baseus", 2200), ("Samsung", 3500),
                         ("Xiaomi", 2000), ("Remax", 1500), ("Generic", 900)]:
        for watt in (10, 15):
            add_item(category="Chargers", brand=brand,
                     name_en=f"{brand} {watt}W Wireless Charger Pad",
                     variant_token=f"WL{watt}", purchase=price + (watt - 10) * 60,
                     colors=["Black", "White"], variants=["Pad", "Stand"])
    # Multi-port / GaN chargers.
    for brand, price in [("Anker", 4200), ("Baseus", 3600), ("Ugreen", 4000),
                         ("Remax", 2200), ("Generic", 1400)]:
        add_item(category="Chargers", brand=brand,
                 name_en=f"{brand} 65W GaN Multi Port Charger 3 Port",
                 variant_token="GAN65", purchase=price,
                 colors=["White", "Black"], variants=["2C+1A"])
        add_item(category="Chargers", brand=brand,
                 name_en=f"{brand} 100W GaN Multi Port Charger 4 Port",
                 variant_token="GAN100", purchase=int(price * 1.6),
                 colors=["White", "Black"], variants=["3C+1A"])


# ---------------------------------------------------------------------------
# 2. Cables
# ---------------------------------------------------------------------------
def build_cables() -> None:
    cable_types = [  # (label, connector, token, base price)
        ("Type-C Cable", "USB-C", "TC", 250),
        ("Micro USB Cable", "Micro USB", "MU", 180),
        ("Lightning Cable", "Lightning", "LT", 350),
        ("Type-C to Type-C Cable", "C-to-C", "CC", 300),
        ("Type-C to Lightning Cable", "C-to-Lightning", "CL", 450),
        ("3-in-1 Multi Cable", "3-in-1", "3IN1", 500),
    ]
    brands = ["Anker", "Baseus", "Ugreen", "Remax", "Hoco", "Oraimo",
              "Faster", "Yison", "Generic"]
    for label, _conn, token, base in cable_types:
        for brand in brands:
            for length, mult in [(1, 1.0), (1.5, 1.2), (2, 1.4)]:
                add_item(category="Cables", brand=brand,
                         name_en=f"{brand} {label} {length}m Fast Charge",
                         variant_token=f"{token}{int(length * 10)}",
                         purchase=int(base * mult * (1.6 if brand in ("Anker", "Ugreen") else 1.0)),
                         colors=["Black", "White"], variants=[f"{length}m"])
            # Braided premium variant, 1m only.
            add_item(category="Cables", brand=brand,
                     name_en=f"{brand} Braided {label} 1m Fast Charge",
                     variant_token=f"{token}BRD", purchase=int(base * 1.8),
                     colors=["Black", "Red", "Blue"], variants=["Braided Nylon", "1m"])


# ---------------------------------------------------------------------------
# 3. Power banks
# ---------------------------------------------------------------------------
def build_power_banks() -> None:
    for brand in ["Anker", "Baseus", "Oraimo", "Xiaomi", "Remax", "Faster",
                  "Ronin", "Generic"]:
        for mah, price in [(5000, 1200), (10000, 1800), (15000, 2300), (20000, 2800), (30000, 4200)]:
            mult = 1.5 if brand == "Anker" else 1.25 if brand in ("Baseus", "Xiaomi") else 1.0
            add_item(category="Power Banks", brand=brand,
                     name_en=f"{brand} {mah}mAh Power Bank Fast Charging",
                     variant_token=f"{mah // 1000}K", purchase=int(price * mult),
                     colors=["Black", "White", "Blue"],
                     variants=["USB-C Input", "Dual Output"])
            add_item(category="Power Banks", brand=brand,
                     name_en=f"{brand} {mah}mAh Mini Power Bank Pocket Size",
                     variant_token=f"{mah // 1000}KMIN", purchase=int(price * mult * 0.9),
                     colors=["Black", "White"],
                     variants=["Pocket Size", "USB-C Input"])
    # Solar + wireless-charging power banks.
    for brand in ["Anker", "Baseus", "Generic"]:
        add_item(category="Power Banks", brand=brand,
                 name_en=f"{brand} 20000mAh Solar Power Bank",
                 variant_token="SOL20", purchase=3200,
                 colors=["Black"], variants=["Solar Panel", "LED Torch"])
        add_item(category="Power Banks", brand=brand,
                 name_en=f"{brand} 10000mAh Wireless Power Bank",
                 variant_token="WL10", purchase=3000,
                 colors=["Black", "White"], variants=["MagSafe", "15W Wireless"])


# ---------------------------------------------------------------------------
# 4. Handsfree & audio
# ---------------------------------------------------------------------------
def build_audio() -> None:
    # Wired handsfree.
    for brand in ["Samsung", "Xiaomi", "Remax", "Hoco", "Audionic",
                  "Ronin", "Faster", "Generic"]:
        for jack in ("3.5mm", "Type-C"):
            add_item(category="Audio", brand=brand,
                     name_en=f"{brand} Wired Handsfree {jack} with Mic",
                     variant_token=f"WHF{jack[0]}", purchase=350 if brand == "Generic" else 600,
                     colors=["Black", "White"], variants=[jack, "In-Ear"])
    # Bluetooth handsfree (single ear).
    for brand in ["Remax", "Hoco", "Audionic", "Ronin", "Generic"]:
        add_item(category="Audio", brand=brand,
                 name_en=f"{brand} Bluetooth Handsfree Single Ear with Mic",
                 variant_token="BHF", purchase=900,
                 colors=["Black"], variants=["BT 5.0"])
    # TWS earbuds.
    for brand, price in [("Anker", 4500), ("QCY", 2800), ("Realme", 3200),
                         ("Xiaomi", 3000), ("Oraimo", 2500), ("Audionic", 1800),
                         ("Ronin", 2200), ("Samsung", 6500), ("Apple", 12000),
                         ("Baseus", 3800), ("Remax", 1600), ("Generic", 900)]:
        add_item(category="Audio", brand=brand,
                 name_en=f"{brand} Wireless Earbuds TWS Bluetooth",
                 variant_token="TWS", purchase=price,
                 colors=["Black", "White"], variants=["BT 5.3", "Charging Case"])
        add_item(category="Audio", brand=brand,
                 name_en=f"{brand} Wireless Earbuds TWS Pro with ENC Mic",
                 variant_token="TWSPRO", purchase=int(price * 1.4),
                 colors=["Black", "White"], variants=["ENC", "Touch Control"])
    # Neckbands.
    for brand, price in [("Audionic", 1200), ("Ronin", 1500), ("Oraimo", 1800),
                         ("Remax", 1100), ("Realme", 2200), ("Xiaomi", 2000),
                         ("Generic", 700)]:
        add_item(category="Audio", brand=brand,
                 name_en=f"{brand} Bluetooth Neckband Handsfree",
                 variant_token="NKB", purchase=price,
                 colors=["Black", "Blue"], variants=["BT 5.0", "Magnetic Buds"])
    # Headphones (over-ear).
    for brand, price in [("JBL", 6500), ("Anker", 5500), ("Baseus", 4200),
                         ("Audionic", 2200), ("Ronin", 2800), ("Remax", 1800),
                         ("Generic", 1200)]:
        add_item(category="Audio", brand=brand,
                 name_en=f"{brand} Bluetooth Headphones Over Ear",
                 variant_token="HP", purchase=price,
                 colors=["Black", "Blue"], variants=["Foldable", "40h Battery"])
        add_item(category="Audio", brand=brand,
                 name_en=f"{brand} Wired Headphones with Mic",
                 variant_token="WHP", purchase=int(price * 0.45),
                 colors=["Black"], variants=["3.5mm Jack"])
    # Bluetooth speakers.
    for brand, price in [("JBL", 5500), ("Anker", 4800), ("Audionic", 1800),
                         ("Ronin", 2200), ("Remax", 1500), ("Generic", 900)]:
        add_item(category="Audio", brand=brand,
                 name_en=f"{brand} Bluetooth Speaker Portable",
                 variant_token="SPK", purchase=price,
                 colors=["Black", "Blue", "Red"], variants=["Portable", "USB + AUX"])
        add_item(category="Audio", brand=brand,
                 name_en=f"{brand} Bluetooth Speaker Mini with LED",
                 variant_token="SPKM", purchase=int(price * 0.6),
                 colors=["Black", "Blue"], variants=["Mini", "LED Light"])


# ---------------------------------------------------------------------------
# 5. Protection — covers & glass mapped to device models (the big matrix)
# ---------------------------------------------------------------------------
COVER_TYPES = [  # (label, token, purchase price)
    ("Silicone Back Cover", "SIL", 250),
    ("Clear TPU Back Cover", "CLR", 300),
    ("Hard Back Cover", "HRD", 350),
    ("Leather Flip Back Cover", "LTH", 550),
]
GLASS_TYPES = [
    ("Tempered Glass", "GLS", 150),
    ("9D Tempered Glass", "9D", 250),
    ("Privacy Tempered Glass", "PRV", 350),
    ("Matte Tempered Glass", "MAT", 300),
]


def _device_label(device: tuple[str, str]) -> str:
    return f"{device[0]} {device[1]}"


def build_protection() -> None:
    for device in DEVICE_MODELS:
        label = _device_label(device)
        for cover_label, token, price in COVER_TYPES:
            add_item(category="Protection", brand="Generic",
                     name_en=f"{cover_label} for {label}",
                     variant_token=token, purchase=price,
                     model_compatibility=label, device=device,
                     colors=["Black", "Blue", "Red", "Transparent"],
                     variants=[cover_label])
        for glass_label, token, price in GLASS_TYPES[:2]:  # normal + 9D
            add_item(category="Protection", brand="Generic",
                     name_en=f"{glass_label} for {label}",
                     variant_token=token, purchase=price,
                     model_compatibility=label, device=device,
                     colors=[], variants=["Full Glue", "9H Hardness"])
    # Privacy + matte glass for flagship models only.
    flagships = [d for d in DEVICE_MODELS if d[0] in ("Apple", "Samsung")
                 and any(k in d[1] for k in ("Pro", "Ultra", "S23", "S24"))]
    for device in flagships:
        label = _device_label(device)
        for glass_label, token, price in GLASS_TYPES[2:]:
            add_item(category="Protection", brand="Generic",
                     name_en=f"{glass_label} for {label}",
                     variant_token=token, purchase=price,
                     model_compatibility=label, device=device,
                     colors=[], variants=["Full Glue"])
    # Branded covers for Apple / Samsung flagships.
    for device in [d for d in DEVICE_MODELS if d[0] == "Apple"][:12]:
        label = _device_label(device)
        add_item(category="Protection", brand="Apple",
                 name_en=f"Apple Silicone Back Cover for {label}",
                 variant_token="SIL", purchase=1800,
                 model_compatibility=label, device=device,
                 colors=["Black", "Blue", "Pink"], variants=["Original Style"])
    # Camera lens protectors (iPhone + Samsung flagships).
    for device in flagships[:20]:
        label = _device_label(device)
        add_item(category="Protection", brand="Generic",
                 name_en=f"Camera Lens Protector for {label}",
                 variant_token="LENS", purchase=300,
                 model_compatibility=label, device=device,
                 colors=["Clear", "Black"], variants=["Tempered Glass"])
    # Pop sockets / grips (generic, no device mapping).
    for design, price in [("Plain", 150), ("Glitter", 200), ("Ring Grip", 250),
                          ("MagSafe Ring", 400)]:
        add_item(category="Protection", brand="Generic",
                 name_en=f"Pop Socket Phone Grip {design}",
                 variant_token="POP", purchase=price,
                 colors=["Black", "White", "Gold", "Pink"],
                 variants=["Adhesive", "360 Rotate"])


# ---------------------------------------------------------------------------
# 6. Phone holders
# ---------------------------------------------------------------------------
def build_holders() -> None:
    for brand, price in [("Baseus", 1200), ("Remax", 800), ("Hoco", 700),
                         ("Generic", 400)]:
        add_item(category="Holders", brand=brand,
                 name_en=f"{brand} Car Holder Magnetic Dashboard Mount",
                 variant_token="CARMAG", purchase=price,
                 colors=["Black"], variants=["Magnetic", "360 Rotate"])
        add_item(category="Holders", brand=brand,
                 name_en=f"{brand} Car Holder Air Vent Clip Mount",
                 variant_token="CARVENT", purchase=int(price * 0.8),
                 colors=["Black"], variants=["Vent Clip"])
        add_item(category="Holders", brand=brand,
                 name_en=f"{brand} Car Holder Windshield Suction Mount",
                 variant_token="CARSUC", purchase=int(price * 0.9),
                 colors=["Black"], variants=["Suction Cup"])
    for brand, price in [("Remax", 1500), ("Hoco", 1200), ("Generic", 700)]:
        add_item(category="Holders", brand=brand,
                 name_en=f"{brand} Selfie Stick with Bluetooth Remote",
                 variant_token="SELFIE", purchase=price,
                 colors=["Black", "White"], variants=["Extendable", "BT Remote"])
        add_item(category="Holders", brand=brand,
                 name_en=f"{brand} Tripod Stand with Phone Holder",
                 variant_token="TRIPOD", purchase=int(price * 1.2),
                 colors=["Black"], variants=["Adjustable Height"])
    for size, price in [(10, 1200), (12, 1800), (18, 2800)]:
        add_item(category="Holders", brand="Generic",
                 name_en=f"{size} inch LED Ring Light with Tripod Stand",
                 variant_token=f"RING{size}", purchase=price,
                 colors=["White"], variants=["3 Light Modes", "USB Powered"])
    for brand, price in [("Baseus", 4500), ("Remax", 2800), ("Generic", 1800)]:
        add_item(category="Holders", brand=brand,
                 name_en=f"{brand} Mobile Gimbal Stabilizer 3 Axis",
                 variant_token="GIMBAL", purchase=price,
                 colors=["Black"], variants=["3-Axis", "BT Control"])
    for brand, price in [("Generic", 500), ("Remax", 900)]:
        add_item(category="Holders", brand=brand,
                 name_en=f"{brand} Desktop Phone Stand Foldable",
                 variant_token="DESK", purchase=price,
                 colors=["Black", "Silver"], variants=["Foldable", "Adjustable Angle"])
        add_item(category="Holders", brand=brand,
                 name_en=f"{brand} Bike Holder Mobile Mount",
                 variant_token="BIKE", purchase=int(price * 1.1),
                 colors=["Black"], variants=["Handlebar Clamp"])


# ---------------------------------------------------------------------------
# 7. Memory & storage
# ---------------------------------------------------------------------------
def build_memory() -> None:
    for brand in ["SanDisk", "Kingston", "Samsung"]:
        for gb, price in [(16, 700), (32, 900), (64, 1300), (128, 2000), (256, 3800)]:
            add_item(category="Memory", brand=brand,
                     name_en=f"{brand} Micro SD Memory Card {gb}GB Class 10",
                     variant_token=f"SD{gb}", purchase=price,
                     colors=[], variants=[f"{gb}GB", "Class 10"])
    for brand in ["SanDisk", "Kingston"]:
        for gb, price in [(32, 1100), (64, 1600), (128, 2600)]:
            add_item(category="Memory", brand=brand,
                     name_en=f"{brand} USB Flash Drive {gb}GB USB 3.0",
                     variant_token=f"USB{gb}", purchase=price,
                     colors=["Black", "Silver"], variants=[f"{gb}GB", "USB 3.0"])
            add_item(category="Memory", brand=brand,
                     name_en=f"{brand} OTG Flash Drive Type-C {gb}GB",
                     variant_token=f"OTG{gb}", purchase=int(price * 1.3),
                     colors=["Silver"], variants=[f"{gb}GB", "Type-C"])
    for brand in ["SanDisk", "Generic"]:
        add_item(category="Memory", brand=brand,
                 name_en=f"{brand} Micro SD Card Reader USB",
                 variant_token="READER", purchase=400 if brand == "Generic" else 800,
                 colors=["Black", "White"], variants=["USB 2.0"])
        add_item(category="Memory", brand=brand,
                 name_en=f"{brand} Type-C Card Reader OTG",
                 variant_token="CREADER", purchase=600 if brand == "Generic" else 1100,
                 colors=["Black"], variants=["Type-C", "SD + MicroSD"])


# ---------------------------------------------------------------------------
# 8. Smart accessories
# ---------------------------------------------------------------------------
def build_smart() -> None:
    for brand, price in [("Xiaomi", 5500), ("Realme", 4800), ("Oraimo", 3200),
                         ("Samsung", 12000), ("Apple", 25000), ("Remax", 2800),
                         ("Hoco", 3000), ("Generic", 1800)]:
        add_item(category="Smart Accessories", brand=brand,
                 name_en=f"{brand} Smart Watch Bluetooth Calling",
                 variant_token="WATCH", purchase=price,
                 colors=["Black", "Silver", "Blue"],
                 variants=["AMOLED", "BT Calling"])
        add_item(category="Smart Accessories", brand=brand,
                 name_en=f"{brand} Smart Watch Ultra Big Display",
                 variant_token="WATCHU", purchase=int(price * 1.3),
                 colors=["Black", "Orange"], variants=["49mm", "BT Calling"])
    for brand, price in [("Xiaomi", 2800), ("Realme", 2500), ("Oraimo", 1800),
                         ("Generic", 1200)]:
        add_item(category="Smart Accessories", brand=brand,
                 name_en=f"{brand} Fitness Band Smart Bracelet",
                 variant_token="BAND", purchase=price,
                 colors=["Black", "Blue"], variants=["Heart Rate", "Step Counter"])
    for strap, price in [("Silicone", 400), ("Leather", 800), ("Metal Chain", 1200),
                         ("Nylon Sport", 500)]:
        add_item(category="Smart Accessories", brand="Generic",
                 name_en=f"Smart Watch Strap {strap} Universal 22mm",
                 variant_token="STRAP", purchase=price,
                 colors=["Black", "Brown", "Blue"], variants=["22mm", "Quick Release"])
    for brand, price in [("Apple", 3500), ("Samsung", 2800), ("Generic", 1200)]:
        add_item(category="Smart Accessories", brand=brand,
                 name_en=f"{brand} Bluetooth Tracker Tag",
                 variant_token="TRACK", purchase=price,
                 colors=["White", "Black"], variants=["Find My", "CR2032 Battery"])


# ---------------------------------------------------------------------------
# 9. Repair parts
# ---------------------------------------------------------------------------
def build_repair_parts() -> None:
    # LCD / screens for the most common models (with/without frame).
    lcd_models = DEVICE_MODELS[:70]
    for device in lcd_models:
        label = _device_label(device)
        price = 4500 if device[0] == "Apple" else 3500 if device[0] == "Samsung" else 2500
        add_item(category="Repair Parts", brand="Generic",
                 name_en=f"LCD Screen Complete for {label}",
                 variant_token="LCD", purchase=price,
                 model_compatibility=label, device=device,
                 colors=[], variants=["With Touch", "IPS"])
    for device in lcd_models[:25]:
        label = _device_label(device)
        price = 5500 if device[0] == "Apple" else 4200 if device[0] == "Samsung" else 3200
        add_item(category="Repair Parts", brand="Generic",
                 name_en=f"LCD Screen with Frame for {label}",
                 variant_token="LCDFRM", purchase=price,
                 model_compatibility=label, device=device,
                 colors=[], variants=["With Frame", "With Touch"])
    # Batteries for common models.
    for device in DEVICE_MODELS[:60]:
        label = _device_label(device)
        price = 1800 if device[0] == "Apple" else 1200 if device[0] == "Samsung" else 900
        add_item(category="Repair Parts", brand="Generic",
                 name_en=f"Mobile Battery for {label}",
                 variant_token="BAT", purchase=price,
                 model_compatibility=label, device=device,
                 colors=[], variants=["Li-ion"])
    # Charging ports / flex cables.
    for device in DEVICE_MODELS[:40]:
        label = _device_label(device)
        add_item(category="Repair Parts", brand="Generic",
                 name_en=f"Charging Port Flex Cable for {label}",
                 variant_token="CCFLEX", purchase=350,
                 model_compatibility=label, device=device,
                 colors=[], variants=["Charging Port + Mic"])
    # Speakers, mics, earpieces (generic, fit-many).
    for part, price in [("Loud Speaker", 250), ("Earpiece Speaker", 200),
                        ("Microphone Mic", 150), ("Vibrator Motor", 200)]:
        for brand in ["Generic", "Samsung", "Xiaomi"]:
            add_item(category="Repair Parts", brand=brand,
                     name_en=f"{part} Replacement {brand}",
                     variant_token="SPARE", purchase=price,
                     colors=[], variants=["Original Quality"])
    # Back glass for iPhone / Samsung flagships.
    for device in [d for d in DEVICE_MODELS if d[0] in ("Apple", "Samsung")][:25]:
        label = _device_label(device)
        add_item(category="Repair Parts", brand="Generic",
                 name_en=f"Back Glass Panel for {label}",
                 variant_token="BGLASS", purchase=900,
                 model_compatibility=label, device=device,
                 colors=["Black", "White", "Blue"], variants=["With Adhesive"])
    # Tool kits.
    for kit, price in [("Basic Mobile Repair Tool Kit 10 in 1", 800),
                       ("Professional Repair Tool Kit 30 in 1", 2200),
                       ("Screwdriver Set Precision 24 in 1", 900),
                       ("Opening Pry Tool Set", 400),
                       ("Hot Air Gun for Mobile Repair", 6500)]:
        add_item(category="Repair Parts", brand="Generic",
                 name_en=kit, variant_token="TOOL", purchase=price,
                 colors=[], variants=["Steel"])


# ---------------------------------------------------------------------------
# 10. Others
# ---------------------------------------------------------------------------
def build_others() -> None:
    for device in DEVICE_MODELS[:40]:
        label = _device_label(device)
        add_item(category="Others", brand="Generic",
                 name_en=f"SIM Tray for {label}",
                 variant_token="SIM", purchase=150,
                 model_compatibility=label, device=device,
                 colors=["Black", "Silver", "Gold"], variants=["Single/Dual"])
    for pack, price in [("Ejector Pin Pack of 10", 100), ("Ejector Pin Single", 30)]:
        add_item(category="Others", brand="Generic",
                 name_en=f"SIM Ejector Pin {pack}", variant_token="PIN",
                 purchase=price, colors=["Silver"], variants=[], unit="pack" if "Pack" in pack else "piece")
    adapters = [
        ("Type-C to 3.5mm Audio Adapter", 350, "ADPT"),
        ("Lightning to 3.5mm Audio Adapter", 450, "ADPT"),
        ("Type-C to USB OTG Adapter", 250, "ADPT"),
        ("Micro USB to Type-C Adapter", 200, "ADPT"),
        ("HDMI to Type-C Adapter", 1500, "ADPT"),
        ("USB Hub 4 Port Adapter", 900, "ADPT"),
    ]
    for name, price, token in adapters:
        add_item(category="Others", brand="Generic", name_en=name,
                 variant_token=token, purchase=price, colors=["Black", "Silver"])
    for name, price in [("HDMI Cable 1.5m", 600), ("HDMI Cable 3m", 900),
                        ("VGA Cable 1.5m", 500), ("Ethernet Cable 5m", 450)]:
        add_item(category="Others", brand="Generic", name_en=name,
                 variant_token="HDMI", purchase=price, colors=["Black"], unit="piece")
    for name, price in [("Laptop Charger 65W Universal", 2500),
                        ("Laptop Stand Foldable Aluminium", 1800),
                        ("Wireless Mouse", 900), ("Wireless Keyboard", 1600),
                        ("Mouse Pad Large", 350)]:
        add_item(category="Others", brand="Generic", name_en=name,
                 variant_token="LAP", purchase=price, colors=["Black", "Silver"])
    for name, price in [("Mobile Gaming Trigger Pair", 600),
                        ("Mobile Gaming Controller Bluetooth", 2500),
                        ("Gaming Finger Sleeves Pack of 2", 200),
                        ("Cooling Fan for Mobile Gaming", 1200)]:
        add_item(category="Others", brand="Generic", name_en=name,
                 variant_token="GAME", purchase=price, colors=["Black"])


BUILDERS = [build_chargers, build_cables, build_power_banks, build_audio,
            build_protection, build_holders, build_memory, build_smart,
            build_repair_parts, build_others]


# ---------------------------------------------------------------------------
# Output writers
# ---------------------------------------------------------------------------
def _sql_str(value: str | None) -> str:
    if value is None:
        return "NULL"
    return "'" + value.replace("'", "''") + "'"


def _jsonb(value) -> str:
    return "$json$" + json.dumps(value, ensure_ascii=False) + "$json$"


def build_sql(version: str, generated_at: str, item_count: int) -> str:
    lines: list[str] = []
    lines.append("-- Accessories Master Catalog — migration 001")
    lines.append("-- Generated by scripts/generate_catalog.py — DO NOT hand-edit.")
    lines.append(f"-- Version {version} · generated {generated_at} · {item_count} items.")
    lines.append("-- All prices are ESTIMATED Punjab-market prices (whole PKR),")
    lines.append("-- marked estimated=true. Never live market rates.")
    lines.append("-- Idempotent: safe to re-run. First load inserts with")
    lines.append("-- ON CONFLICT (sku) DO NOTHING; the commented block at the end")
    lines.append("-- shows how a version update refreshes estimated prices only")
    lines.append("-- (never stock, never shopkeeper prices, never custom items).")
    lines.append("-- This migration creates NEW catalog_* tables only; it does not")
    lines.append("-- modify any existing table.")
    lines.append("")
    lines.append("BEGIN;")
    lines.append("")
    lines.append("CREATE TABLE IF NOT EXISTS catalog_versions (")
    lines.append("  version TEXT PRIMARY KEY,")
    lines.append("  applied_at TIMESTAMPTZ NOT NULL DEFAULT now(),")
    lines.append("  item_count INT NOT NULL DEFAULT 0,")
    lines.append("  notes TEXT")
    lines.append(");")
    lines.append("")
    lines.append("CREATE TABLE IF NOT EXISTS catalog_categories (")
    lines.append("  id SERIAL PRIMARY KEY,")
    lines.append("  name_en TEXT NOT NULL UNIQUE,")
    lines.append("  name_ur TEXT NOT NULL DEFAULT '',")
    lines.append("  sort_order INT NOT NULL DEFAULT 0")
    lines.append(");")
    lines.append("")
    lines.append("CREATE TABLE IF NOT EXISTS catalog_items (")
    lines.append("  sku TEXT PRIMARY KEY,")
    lines.append("  category TEXT NOT NULL,")
    lines.append("  brand TEXT NOT NULL,")
    lines.append("  name_en TEXT NOT NULL,")
    lines.append("  name_ur TEXT NOT NULL DEFAULT '',")
    lines.append("  model_compatibility TEXT,")
    lines.append("  colors JSONB NOT NULL DEFAULT '[]'::jsonb,")
    lines.append("  variants JSONB NOT NULL DEFAULT '[]'::jsonb,")
    lines.append("  purchase_price_est INT NOT NULL DEFAULT 0 CHECK (purchase_price_est >= 0),")
    lines.append("  sale_price_est INT NOT NULL DEFAULT 0 CHECK (sale_price_est >= 0),")
    lines.append("  min_price INT NOT NULL DEFAULT 0 CHECK (min_price >= 0),")
    lines.append("  unit TEXT NOT NULL DEFAULT 'piece',")
    lines.append("  barcode TEXT UNIQUE,")
    lines.append("  is_custom BOOLEAN NOT NULL DEFAULT FALSE,")
    lines.append("  estimated BOOLEAN NOT NULL DEFAULT TRUE,")
    lines.append("  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),")
    lines.append("  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()")
    lines.append(");")
    lines.append("CREATE INDEX IF NOT EXISTS idx_catalog_items_category ON catalog_items (category);")
    lines.append("CREATE INDEX IF NOT EXISTS idx_catalog_items_brand ON catalog_items (brand);")
    lines.append("CREATE INDEX IF NOT EXISTS idx_catalog_items_name ON catalog_items (name_en);")
    lines.append("")
    lines.append("CREATE TABLE IF NOT EXISTS catalog_item_models (")
    lines.append("  sku TEXT NOT NULL REFERENCES catalog_items (sku) ON DELETE CASCADE,")
    lines.append("  device_brand TEXT NOT NULL,")
    lines.append("  device_model TEXT NOT NULL,")
    lines.append("  PRIMARY KEY (sku, device_brand, device_model)")
    lines.append(");")
    lines.append("")
    lines.append("CREATE TABLE IF NOT EXISTS barcode_links (")
    lines.append("  barcode TEXT PRIMARY KEY,")
    lines.append("  sku TEXT NOT NULL REFERENCES catalog_items (sku) ON DELETE CASCADE,")
    lines.append("  linked_at TIMESTAMPTZ NOT NULL DEFAULT now()")
    lines.append(");")
    lines.append("")
    lines.append("CREATE TABLE IF NOT EXISTS catalog_stock (")
    lines.append("  sku TEXT PRIMARY KEY REFERENCES catalog_items (sku) ON DELETE CASCADE,")
    lines.append("  quantity INT NOT NULL DEFAULT 0 CHECK (quantity >= 0),")
    lines.append("  last_purchase_price INT,")
    lines.append("  last_supplier TEXT,")
    lines.append("  last_stock_date TIMESTAMPTZ,")
    lines.append("  low_stock_threshold INT NOT NULL DEFAULT 5")
    lines.append(");")
    lines.append("")
    lines.append("CREATE TABLE IF NOT EXISTS stock_counts (")
    lines.append("  id SERIAL PRIMARY KEY,")
    lines.append("  sku TEXT NOT NULL REFERENCES catalog_items (sku) ON DELETE CASCADE,")
    lines.append("  counted_qty INT NOT NULL,")
    lines.append("  system_qty INT NOT NULL,")
    lines.append("  difference INT NOT NULL,")
    lines.append("  note TEXT,")
    lines.append("  counted_by TEXT,")
    lines.append("  counted_at TIMESTAMPTZ NOT NULL DEFAULT now()")
    lines.append(");")
    lines.append("CREATE INDEX IF NOT EXISTS idx_stock_counts_sku ON stock_counts (sku);")
    lines.append("")
    # Categories.
    lines.append("-- Categories")
    for name_en, _name_ur_unused, name_ur, sort_order in [
        (c[0], c[1], c[2], c[3]) for c in CATEGORIES
    ]:
        lines.append(
            f"INSERT INTO catalog_categories (name_en, name_ur, sort_order) "
            f"VALUES ({_sql_str(name_en)}, {_sql_str(name_ur)}, {sort_order}) "
            f"ON CONFLICT (name_en) DO NOTHING;"
        )
    lines.append("")
    # Items, batched 200 per INSERT for readability.
    lines.append("-- Catalog items (first load: ON CONFLICT DO NOTHING)")
    cols = ("sku, category, brand, name_en, name_ur, model_compatibility, "
            "colors, variants, purchase_price_est, sale_price_est, min_price, "
            "unit, barcode, is_custom, estimated")
    for start in range(0, len(items), 200):
        batch = items[start:start + 200]
        lines.append(f"INSERT INTO catalog_items ({cols}) VALUES")
        value_lines = []
        for it in batch:
            value_lines.append(
                "(" + ", ".join([
                    _sql_str(it["sku"]), _sql_str(it["category"]), _sql_str(it["brand"]),
                    _sql_str(it["name_en"]), _sql_str(it["name_ur"]),
                    _sql_str(it["model_compatibility"]),
                    _jsonb(it["colors"]), _jsonb(it["variants"]),
                    str(it["purchase_price_est"]), str(it["sale_price_est"]),
                    str(it["min_price"]), _sql_str(it["unit"]),
                    _sql_str(it["barcode"]),
                    "TRUE" if it["is_custom"] else "FALSE",
                    "TRUE" if it["estimated"] else "FALSE",
                ]) + ")"
            )
        lines.append(",\n".join(value_lines))
        lines.append("ON CONFLICT (sku) DO NOTHING;")
        lines.append("")
    # Model links.
    lines.append("-- Device-model links (covers / glass / repair parts)")
    for start in range(0, len(_model_links), 200):
        batch = _model_links[start:start + 200]
        lines.append("INSERT INTO catalog_item_models (sku, device_brand, device_model) VALUES")
        lines.append(",\n".join(
            f"({_sql_str(m['sku'])}, {_sql_str(m['device_brand'])}, {_sql_str(m['device_model'])})"
            for m in batch
        ))
        lines.append("ON CONFLICT DO NOTHING;")
        lines.append("")
    # Zero stock rows.
    lines.append("-- Opening stock rows (quantity 0; stock-in fills them later)")
    for start in range(0, len(items), 500):
        batch = items[start:start + 500]
        lines.append("INSERT INTO catalog_stock (sku, quantity, low_stock_threshold) VALUES")
        lines.append(",\n".join(
            f"({_sql_str(it['sku'])}, 0, {it['low_stock_threshold']})" for it in batch
        ))
        lines.append("ON CONFLICT (sku) DO NOTHING;")
        lines.append("")
    # Version record.
    lines.append("-- Version record")
    lines.append(
        f"INSERT INTO catalog_versions (version, item_count, notes) VALUES "
        f"({_sql_str(version)}, {item_count}, "
        f"{_sql_str('Initial catalog. All prices are ESTIMATED Punjab-market prices (whole PKR), not live market rates.')}) "
        f"ON CONFLICT (version) DO NOTHING;"
    )
    lines.append("")
    lines.append("COMMIT;")
    lines.append("")
    lines.append("-- ===============================================================")
    lines.append("-- VERSION UPDATE (how to apply a NEW catalog version — copy this")
    lines.append("-- block, change the version/items, run it in a transaction):")
    lines.append("--   * INSERT new items with ON CONFLICT (sku) DO NOTHING")
    lines.append("--     (new SKUs are added; nothing existing is touched).")
    lines.append("--   * Refresh ESTIMATED prices only, for non-custom items:")
    lines.append("--       INSERT INTO catalog_items (sku, category, brand, name_en,")
    lines.append("--         name_ur, model_compatibility, colors, variants,")
    lines.append("--         purchase_price_est, sale_price_est, min_price, unit,")
    lines.append("--         barcode, is_custom, estimated)")
    lines.append("--       VALUES (...new version rows...)")
    lines.append("--       ON CONFLICT (sku) DO UPDATE SET")
    lines.append("--         purchase_price_est = EXCLUDED.purchase_price_est,")
    lines.append("--         sale_price_est     = EXCLUDED.sale_price_est,")
    lines.append("--         min_price          = EXCLUDED.min_price,")
    lines.append("--         updated_at         = now()")
    lines.append("--       WHERE catalog_items.is_custom = FALSE;")
    lines.append("--   * NEVER touch catalog_stock, barcode_links or is_custom rows")
    lines.append("--     in an update — stock, shopkeeper prices and custom items")
    lines.append("--     are preserved. Then INSERT the new catalog_versions row.")
    lines.append("-- ===============================================================")
    return "\n".join(lines) + "\n"


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
def main() -> int:
    parser = argparse.ArgumentParser(description="Generate the accessories catalog.")
    parser.add_argument("--out-dir", type=Path, default=PROJECT_ROOT,
                        help="Project root (default: parent of scripts/)")
    parser.add_argument("--check", action="store_true",
                        help="Validate the generated files without rewriting them")
    args = parser.parse_args()

    for builder in BUILDERS:
        builder()

    generated_at = datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")
    payload = {
        "version": VERSION,
        "generated_at": generated_at,
        "item_count": len(items),
        "price_note": ("All prices are ESTIMATED Punjab-market prices in whole PKR "
                       "at generation time. They are NOT live market rates. The "
                       "shopkeeper confirms the real buying price at stock-in."),
        "items": items,
    }
    json_path = args.out_dir / "database" / "catalog" / "accessories_catalog.json"
    sql_path = args.out_dir / "database" / "migrations" / "001_accessories_catalog.sql"

    if not args.check:
        json_path.parent.mkdir(parents=True, exist_ok=True)
        sql_path.parent.mkdir(parents=True, exist_ok=True)
        json_path.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n",
                             encoding="utf-8")
        sql_path.write_text(build_sql(VERSION, generated_at, len(items)), encoding="utf-8")

    # ---- Verification ----
    errors: list[str] = []
    counts = Counter(it["category"] for it in items)
    skus = [it["sku"] for it in items]
    if len(items) < 1500:
        errors.append(f"only {len(items)} items (< 1500 required)")
    if len(set(skus)) != len(skus):
        errors.append("duplicate SKUs found")
    if not re.fullmatch(r"ACC-[A-Z]{3}-[A-Z]{3}-[A-Z0-9]{1,6}-\d{3}", skus[0]):
        errors.append(f"SKU format wrong: {skus[0]}")
    required = {"sku", "category", "brand", "name_en", "name_ur",
                "model_compatibility", "colors", "variants", "purchase_price_est",
                "sale_price_est", "min_price", "unit", "barcode", "is_custom",
                "estimated"}
    for it in items:
        missing = required - set(it)
        if missing:
            errors.append(f"{it['sku']} missing fields {missing}")
            break
        if it["purchase_price_est"] <= 0 or it["sale_price_est"] < it["purchase_price_est"]:
            errors.append(f"{it['sku']} has bad prices")
            break
        if it["estimated"] is not True:
            errors.append(f"{it['sku']} is not marked estimated")
            break
    if args.check:
        data = json.loads(json_path.read_text(encoding="utf-8"))
        if data["item_count"] != len(data["items"]):
            errors.append("JSON item_count does not match items length")
        sql = sql_path.read_text(encoding="utf-8")
        for needle in ("CREATE TABLE IF NOT EXISTS catalog_items",
                       "ON CONFLICT (sku) DO NOTHING",
                       "catalog_versions", "stock_counts", "barcode_links"):
            if needle not in sql:
                errors.append(f"SQL missing: {needle}")
        if sql.count("INSERT INTO catalog_items") < 1:
            errors.append("SQL has no catalog_items inserts")

    print(f"Catalog version {VERSION} · generated {generated_at}")
    print(f"Total items: {len(items)}")
    for name, _u, _ur, _s in CATEGORIES:
        print(f"  {name}: {counts.get(name, 0)}")
    print(f"Device-model links: {len(_model_links)}")
    print(f"Sample SKUs: {', '.join(skus[:5])}")
    print(f"JSON: {json_path}")
    print(f"SQL:  {sql_path}")
    if errors:
        print("VERIFICATION FAILED:")
        for e in errors:
            print(f"  - {e}")
        return 1
    print("Verification: OK (1500+ items, unique SKUs, valid prices, estimated=true)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
