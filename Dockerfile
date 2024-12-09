FROM quay.io/jupyter/minimal-notebook:6552376c71d3

COPY conda-linux-64.lock /tmp/conda-linux-64.lock



RUN mamba update --quiet --file /tmp/conda-linux-64.lock \
    && mamba clean --all -y -f \
    && fix-permissions "${CONDA_DIR}" \
    && fix-permissions "/home/${NB_USER}"

RUN pip install pyyaml==6.0.2
