#!/bin/bash

# Basic settings for the model
models=("resnet" "cnn" "lstm")
datasets=("ECG5000" "FordA" "FordB" "Wafer")

echo -e "Available models: \t ${models[@]}"
echo -e "Available datasets: \t ${datasets[@]}"
echo "-----"

path="./models/"

base_model_url="https://data.time-series-xai.dbvis.de/models/"

for model in "${models[@]}"; do

    for dataset in "${datasets[@]}"; do

        # Convert model and dataset names to lower case
        model_lowercase=$(echo "$model" | tr '[:upper:]' '[:lower:]')
        dataset_lowercase=$(echo "$dataset" | tr '[:upper:]' '[:lower:]')

        echo "Looking for $model_lowercase-$dataset_lowercase.pt..."

        # Check if the model is available locally
        if ! ls "$path$model_lowercase-$dataset_lowercase.pt" 1> /dev/null 2>&1; then

            echo "Model not found locally, checking online next..."

            url="$base_model_url$model_lowercase-$dataset_lowercase.pt"
            online_available=$(curl -o /dev/null --silent --head --write-out '%{http_code}' "$url")

            # Check if the model is available online
            if [ "$online_available" -eq 200 ]; then

                # Donwload model if available
                curl -O "$url" -o "$path$model_lowercase-$dataset_lowercase.pt"

            else

                # Train model if not locally and not online available
                echo "Model not found locally or online. Calling Python training script..."
                python ./scripts/train_model.py -d "$dataset" -m "$model" -p "$path"

            fi

        else

            echo "Model already exist."

        fi

    done
done

echo "All models locally available."
