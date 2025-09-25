import tensorflow as tf
from src.config import load_config
from .ios_converter import convert_ios
from .android_converter import convert_android

from typing import Optional, Tuple, List

try:
    from coremltools.models.model import MLModel
except Exception:
    MLModel = object

def convert(model: tf.keras.Model, labels: Optional[List[str]] = None) -> Tuple[MLModel, bytes]: # type: ignore
    ios_model = convert_ios(model, labels)
    android_model = convert_android(model)
    return ios_model, android_model
