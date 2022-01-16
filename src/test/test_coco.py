import fiftyone as fo

# Print your current config
print(fo.config)

dataset = fo.zoo.load_zoo_dataset(
    "coco-2017",
    split="validation",
    label_types=["detections", "segmentations"],
    classes=["person", "car"],
    max_samples=50,
)

# Visualize the dataset in the FiftyOne App
session = fo.launch_app(dataset)

session.wait()