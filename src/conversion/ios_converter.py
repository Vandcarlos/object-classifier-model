"""
convert.py
Converte modelo Keras (.h5) para Core ML (.mlpackage) com suporte a classificação.
Adiciona classLabel para que o Vision retorne VNClassificationObservation.
"""

import tensorflow as tf
import coremltools as ct

from typing import Optional, List

def convert_ios(model: tf.keras.Model, labels: Optional[List[str]] = None):
    kwargs = {
        "model": model,
        "inputs": [ct.ImageType(shape=(1, 224, 224, 3), scale=1/255.0)]
    }

    classifier_config = generate_classifer_config(model, labels)

    if classifier_config is not None:
        kwargs["classifier_config"] = ct.ClassifierConfig(class_labels=labels)

    mlmodel = ct.convert(**kwargs)
    return mlmodel

def generate_classifer_config(model, labels):
    if labels is not None:
        num_classes = model.output_shape[-1]

        if len(labels) != num_classes:
            raise ValueError(
                f"Número de labels ({len(labels)}) não bate com a saída do modelo ({num_classes})"
            )
    
        ct.ClassifierConfig(class_labels=labels)

    else:
        return None
