cd $(dirname $0)

./install_deps.sh
./build_image.sh
./upload_to_eks.sh
./turnup_cluster.sh

