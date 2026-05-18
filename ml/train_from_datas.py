"""
Train voice_mood.tflite from:
  - ../datas          (RAVDESS: Actor_*/*.wav)
  - ../CREMA-D/AudioWAV/*.wav

Run from hibiki1:  python ml/train_from_datas.py
"""
from __future__ import annotations

import sys
from pathlib import Path

import librosa
import numpy as np
import tensorflow as tf
from sklearn.metrics import classification_report
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder

ROOT = Path(__file__).resolve().parent.parent.parent  # c:/projects/hibi
RAVDESS_DIR = ROOT / "datas"
CREMA_DIR = ROOT / "CREMA-D" / "AudioWAV"
OUT_DIR = Path(__file__).resolve().parent / "output"
ASSETS_DIR = Path(__file__).resolve().parent.parent / "assets" / "models"

SAMPLE_RATE = 16000
DURATION_SEC = 3.0
N_MFCC = 20
N_FFT = 512
HOP_LENGTH = 256
N_MELS = 40
TARGET_SAMPLES = int(SAMPLE_RATE * DURATION_SEC)

LABELS = ["calm", "joyful", "tense"]

RAVDESS_EMOTION_TO_MOOD = {
    "01": "calm",
    "02": "calm",
    "03": "joyful",
    "04": "tense",
    "05": "tense",
    "06": "tense",
    "07": "tense",
    "08": "joyful",
}

# CREMA-D: *_*_{NEU|HAP|SAD|ANG|FEA|DIS}_*.wav
CREMA_EMOTION_TO_MOOD = {
    "NEU": "calm",
    "HAP": "joyful",
    "SAD": "tense",
    "ANG": "tense",
    "FEA": "tense",
    "DIS": "tense",
}


def parse_ravdess_mood(wav_path: Path) -> str | None:
    parts = wav_path.stem.split("-")
    if len(parts) < 3:
        return None
    if parts[0] != "03" or parts[1] != "01":
        return None
    return RAVDESS_EMOTION_TO_MOOD.get(parts[2])


def parse_crema_mood(wav_path: Path) -> str | None:
    parts = wav_path.stem.split("_")
    if len(parts) < 3:
        return None
    code = parts[2].upper()
    return CREMA_EMOTION_TO_MOOD.get(code)


def load_audio(path: Path) -> np.ndarray:
    y, _ = librosa.load(path, sr=SAMPLE_RATE, mono=True)
    if len(y) > TARGET_SAMPLES:
        y = y[:TARGET_SAMPLES]
    elif len(y) < TARGET_SAMPLES:
        y = np.pad(y, (0, TARGET_SAMPLES - len(y)))
    return y


def extract_features(path: Path) -> np.ndarray:
    y = load_audio(path)
    mfcc = librosa.feature.mfcc(
        y=y,
        sr=SAMPLE_RATE,
        n_mfcc=N_MFCC,
        n_fft=N_FFT,
        hop_length=HOP_LENGTH,
        n_mels=N_MELS,
    )
    return mfcc.mean(axis=1).astype(np.float32)


def collect_samples() -> tuple[np.ndarray, np.ndarray]:
    X: list[np.ndarray] = []
    y: list[str] = []

    if RAVDESS_DIR.is_dir():
        rav_files = list(RAVDESS_DIR.glob("Actor_*/*.wav"))
        if not rav_files:
            rav_files = list(RAVDESS_DIR.rglob("*.wav"))
        rav_n = 0
        for fp in rav_files:
            mood = parse_ravdess_mood(fp)
            if mood is None:
                continue
            try:
                X.append(extract_features(fp))
                y.append(mood)
                rav_n += 1
            except Exception as e:
                print(f"skip RAVDESS {fp.name}: {e}")
        print(f"RAVDESS clips used: {rav_n}")

    if CREMA_DIR.is_dir():
        crema_n = 0
        for fp in CREMA_DIR.glob("*.wav"):
            mood = parse_crema_mood(fp)
            if mood is None:
                continue
            try:
                X.append(extract_features(fp))
                y.append(mood)
                crema_n += 1
            except Exception as e:
                print(f"skip CREMA {fp.name}: {e}")
        print(f"CREMA-D clips added: {crema_n}")
    else:
        print(f"No CREMA-D folder at {CREMA_DIR}", file=sys.stderr)

    if not X:
        print(
            "No training samples. Expected RAVDESS under datas/ and CREMA-D under CREMA-D/AudioWAV/",
            file=sys.stderr,
        )
        sys.exit(1)

    counts = {lab: sum(1 for t in y if t == lab) for lab in LABELS}
    print(f"Total samples: {len(y)}, per class: {counts}")
    return np.stack(X), np.array(y)


def balance_training_set(X: np.ndarray, y_labels: np.ndarray) -> tuple[np.ndarray, np.ndarray]:
    """Undersample majority classes so calm / joyful / tense are equally represented."""
    rng = np.random.default_rng(42)
    idx_by: dict[str, np.ndarray] = {
        lab: np.where(y_labels == lab)[0] for lab in LABELS
    }
    target = min(len(idx_by[lab]) for lab in LABELS)
    if target < 100:
        return X, y_labels
    picked: list[np.ndarray] = []
    for lab in LABELS:
        idx = idx_by[lab]
        if len(idx) > target:
            idx = rng.choice(idx, size=target, replace=False)
        picked.append(idx)
    all_idx = np.concatenate(picked)
    rng.shuffle(all_idx)
    return X[all_idx], y_labels[all_idx]


def main() -> None:
    X, y = collect_samples()
    print(f"Feature matrix (raw): {X.shape}")

    X, y = balance_training_set(X, y)
    counts = {lab: sum(1 for t in y if t == lab) for lab in LABELS}
    print(f"After balancing: {X.shape[0]} samples, per class: {counts}")

    le = LabelEncoder()
    le.fit(LABELS)
    y_enc = le.transform(y)

    X_train, X_test, y_train, y_test = train_test_split(
        X, y_enc, test_size=0.2, random_state=42, stratify=y_enc
    )

    model = tf.keras.Sequential(
        [
            tf.keras.layers.Input(shape=(N_MFCC,)),
            tf.keras.layers.Dense(96, activation="relu"),
            tf.keras.layers.Dropout(0.35),
            tf.keras.layers.Dense(48, activation="relu"),
            tf.keras.layers.Dropout(0.2),
            tf.keras.layers.Dense(len(LABELS), activation="softmax"),
        ]
    )
    model.compile(
        optimizer=tf.keras.optimizers.Adam(learning_rate=8e-4),
        loss="sparse_categorical_crossentropy",
        metrics=["accuracy"],
    )

    early = tf.keras.callbacks.EarlyStopping(
        monitor="val_accuracy", patience=6, restore_best_weights=True
    )

    model.fit(
        X_train,
        y_train,
        validation_data=(X_test, y_test),
        epochs=60,
        batch_size=48,
        callbacks=[early],
        verbose=1,
    )

    pred = np.argmax(model.predict(X_test, verbose=0), axis=1)
    print(classification_report(y_test, pred, target_names=le.classes_))

    OUT_DIR.mkdir(parents=True, exist_ok=True)
    ASSETS_DIR.mkdir(parents=True, exist_ok=True)

    tflite_path = ASSETS_DIR / "voice_mood.tflite"
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    tflite_path.write_bytes(converter.convert())

    labels_path = ASSETS_DIR / "labels.txt"
    labels_path.write_text("\n".join(le.classes_), encoding="utf-8")

    print(f"Saved: {tflite_path}")
    print(f"Saved: {labels_path}")


if __name__ == "__main__":
    main()
