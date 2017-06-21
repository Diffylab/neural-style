#!/bin/sh
# To use this script, models should be placed in subfolders (see "if nst_nick = ?" operator)

nst_workdir="${HOME}/neural-style" # _inputs/*.* + _styles/*.* => _results/*.png
nst_size=300                # image size
nst_iter=3000               # iterations
nst_save=10                 # save every Nth result, 0 for final only
nst_cw=10 #5                # 1e-10 1e-5 1e-2 1e0 1e1 1e3 1e5 1e7 1e8 1e9 1e10
nst_sw=1000 #300            # 1e-10 1e-5 1e-2 1e0 1e1 1e3 1e5 1e7 1e8 1e9 1e10
nst_scale=1.0
nst_rnd=123
nst_opti=lbfgs #adam #lbfgs

nst_nick="nin_imagenet" #"vgg19"     # content weight  style weight  1280 1450 2150 Mb
# nin_imagenet                         10              1000               570  700
# nin_imagenet_all                     10              1000
# nin_cifar_all                        ?               ?
# illustration2vec                     10              1000
# illustration2vec_3242                10              1000
# illustration2vec_all                 10              1000
# illustration2vec_tag                 10              1000
# illustration2vec_tag_3242            10              1000
# illustration2vec_tag_all             10              1000
# vgg16                                5               100
# vgg16_all                            5               100
# vgg19                                5               300
# vgg19_all                            5               100
# vgg19_conv                           5               100                240  300
# vgg19_conv_all                       5               100
# vgg19_norm                           5*500+ng        100*500+ng    220  240  300
# vgg19_norm_all                       5*500+ng        100*500+ng    190  210  260

nst_ng=""
if [ ${nst_nick} = "nin_imagenet" ]; then # 10 / 1000
  nst_model="models/nin_imagenet/nin_imagenet_conv.caffemodel"
  nst_proto="models/nin_imagenet/train_val.prototxt"
  # d d *cr cr cr P *cr cr cr P *cr cr cr P D cr cr *cr P A L
  nst_cl="relu0,relu3,relu7,relu12"
  nst_sl="relu0,relu3,relu7,relu12"
elif [ ${nst_nick} = "nin_imagenet_all" ]; then # 10 / 1000
  nst_model="models/nin_imagenet/nin_imagenet_conv.caffemodel"
  nst_proto="models/nin_imagenet/train_val.prototxt"
  # d d cr cr cr P cr cr cr P cr cr cr P D cr cr cr P A L
  nst_cl="relu0,relu1,relu2,relu3,relu5,relu6,relu7,relu8,relu9,relu10,relu11,relu12"
  nst_sl="relu0,relu1,relu2,relu3,relu5,relu6,relu7,relu8,relu9,relu10,relu11,relu12"

elif [ ${nst_nick} = "nin_cifar_all" ]; then # ? / ?
  nst_model="models/nin_cifar/cifar10_nin.caffemodel"
  nst_proto="models/nin_cifar/train_val.prototxt "
  nst_cl="relu1,relu_cccp1,relu_cccp2,relu2,relu_cccp3,relu_cccp4,relu3,relu_cccp5,relu_cccp6"
  nst_sl="relu1,relu_cccp1,relu_cccp2,relu2,relu_cccp3,relu_cccp4,relu3,relu_cccp5,relu_cccp6"

elif [ ${nst_nick} = "illustration2vec" ]; then # 10 / 1000
  nst_model="models/Illustration2Vec/illust2vec_tag_ver200.caffemodel"
  nst_proto="models/Illustration2Vec/illust2vec.prototxt"
  nst_cl="relu4_2"
  nst_sl="relu1_1,relu2_1,relu3_1,relu4_1,relu5_1"
elif [ ${nst_nick} = "illustration2vec_3242" ]; then # 10 / 1000
  nst_model="models/Illustration2Vec/illust2vec_tag_ver200.caffemodel"
  nst_proto="models/Illustration2Vec/illust2vec.prototxt"
  nst_cl="relu3_2,relu4_2"
  nst_sl="relu1_1,relu2_1,relu3_1,relu4_1,relu5_1"
elif [ ${nst_nick} = "illustration2vec_all" ]; then # 10 / 1000
  nst_model="models/Illustration2Vec/illust2vec_tag_ver200.caffemodel"
  nst_proto="models/Illustration2Vec/illust2vec.prototxt"
  # cr P cr P cr cr P cr cr P cr cr P cr cr cr I S
  nst_cl="relu1_1,relu2_1,relu3_1,relu3_2,relu4_1,relu4_2,relu5_1,relu5_2,relu6_1,relu6_2,relu6_3"
  nst_sl="relu1_1,relu2_1,relu3_1,relu3_2,relu4_1,relu4_2,relu5_1,relu5_2,relu6_1,relu6_2,relu6_3"

elif [ ${nst_nick} = "illustration2vec_tag" ]; then # 10 / 1000
  nst_model="models/Illustration2Vec/illust2vec_tag_ver200.caffemodel"
  nst_proto="models/illustration2vec/illust2vec_tag.prototxt"
  nst_cl="relu4_2"
  nst_sl="relu1_1,relu2_1,relu3_1,relu4_1,relu5_1"
elif [ ${nst_nick} = "illustration2vec_tag_3242" ]; then # 10 / 1000
  nst_model="models/Illustration2Vec/illust2vec_tag_ver200.caffemodel"
  nst_proto="models/illustration2vec/illust2vec_tag.prototxt"
  nst_cl="relu3_2,relu4_2"
  nst_sl="relu1_1,relu2_1,relu3_1,relu4_1,relu5_1"
elif [ ${nst_nick} = "illustration2vec_tag_all" ]; then # 10 / 1000
  nst_model="models/Illustration2Vec/illust2vec_tag_ver200.caffemodel"
  nst_proto="models/illustration2vec/illust2vec_tag.prototxt"
  # cr P cr P cr cr P cr cr P cr cr P cr cr cr c P S
  nst_cl="relu1_1,relu2_1,relu3_1,relu3_2,relu4_1,relu4_2,relu5_1,relu5_2,relu6_1,relu6_2,relu6_3"
  nst_sl="relu1_1,relu2_1,relu3_1,relu3_2,relu4_1,relu4_2,relu5_1,relu5_2,relu6_1,relu6_2,relu6_3"

elif [ ${nst_nick} = "vgg19_norm" ]; then # 100 / 300000
  nst_model="models/vgg19_normalized/vgg_normalised.caffemodel"
  nst_proto="models/vgg19_normalized/VGG_ILSVRC_19_layers_deploy.prototxt"
  nst_cl="relu4_2"
  nst_sl="relu1_1,relu2_1,relu3_1,relu4_1,relu5_1"
  nst_ng="-normalize_gradients"
elif [ ${nst_nick} = "vgg19_norm_all" ]; then # 100 / 300000
  nst_model="models/vgg19_normalized/vgg_normalised.caffemodel"
  nst_proto="models/vgg19_normalized/VGG_ILSVRC_19_layers_deploy.prototxt"
  nst_cl="relu1_1,relu1_2,relu2_1,relu2_2,relu3_1,relu3_2,relu3_3,relu3_4,relu4_1,relu4_2,relu4_3,relu4_4,relu5_1,relu5_2,relu5_3,relu5_4"
  nst_sl="relu1_1,relu1_2,relu2_1,relu2_2,relu3_1,relu3_2,relu3_3,relu3_4,relu4_1,relu4_2,relu4_3,relu4_4,relu5_1,relu5_2,relu5_3,relu5_4"
  nst_ng="-normalize_gradients"

elif [ ${nst_nick} = "vgg16" ]; then # 5 / 100
  nst_model="models/vgg16/vgg16.caffemodel"
  nst_proto="models/vgg16/vgg16.prototxt"
  nst_cl="relu4_2"
  nst_sl="relu1_1,relu2_1,relu3_1,relu4_1,relu5_1"
elif [ ${nst_nick} = "vgg16_all" ]; then # 5 / 100
  nst_model="models/vgg16/vgg16.caffemodel"
  nst_proto="models/vgg16/vgg16.prototxt"
  nst_cl="relu1_1,relu1_2,relu2_1,relu2_2,relu3_1,relu3_2,relu3_3,relu4_1,relu4_2,relu4_3,relu5_1,relu5_2,relu5_3"
  nst_sl="relu1_1,relu1_2,relu2_1,relu2_2,relu3_1,relu3_2,relu3_3,relu4_1,relu4_2,relu4_3,relu5_1,relu5_2,relu5_3"

elif [ ${nst_nick} = "vgg19" ]; then # 5 / 100
  nst_model="models/vgg19/vgg19.caffemodel"
  nst_proto="models/vgg19/vgg19.prototxt"
  nst_cl="relu4_2"
  nst_sl="relu1_1,relu2_1,relu3_1,relu4_1,relu5_1"
elif [ ${nst_nick} = "vgg19_all" ]; then # 5 / 100
  nst_model="models/vgg19/vgg19.caffemodel"
  nst_proto="models/vgg19/vgg19.prototxt"
  nst_cl="relu1_1,relu1_2,relu2_1,relu2_2,relu3_1,relu3_2,relu3_3,relu3_4,relu4_1,relu4_2,relu4_3,relu4_4,relu5_1,relu5_2,relu5_3,relu5_4"
  nst_sl="relu1_1,relu1_2,relu2_1,relu2_2,relu3_1,relu3_2,relu3_3,relu3_4,relu4_1,relu4_2,relu4_3,relu4_4,relu5_1,relu5_2,relu5_3,relu5_4"

elif [ ${nst_nick} = "vgg19_conv_all" ]; then # 5 / 100
  nst_model="models/vgg19_conv/VGG_ILSVRC_19_layers_conv.caffemodel"
  nst_proto="models/vgg19_conv/VGG_ILSVRC_19_layers_deploy.prototxt"
  nst_cl="relu1_1,relu1_2,relu2_1,relu2_2,relu3_1,relu3_2,relu3_3,relu3_4,relu4_1,relu4_2,relu4_3,relu4_4,relu5_1,relu5_2,relu5_3,relu5_4"
  nst_sl="relu1_1,relu1_2,relu2_1,relu2_2,relu3_1,relu3_2,relu3_3,relu3_4,relu4_1,relu4_2,relu4_3,relu4_4,relu5_1,relu5_2,relu5_3,relu5_4"
else # vgg19_conv                              # 5 / 100
  nst_model="models/vgg19_conv/VGG_ILSVRC_19_layers_conv.caffemodel"
  nst_proto="models/vgg19_conv/VGG_ILSVRC_19_layers_deploy.prototxt"
  nst_cl="relu4_2"
  nst_sl="relu1_1,relu2_1,relu3_1,relu4_1,relu5_1"
fi

nst_insubdir="${nst_workdir}/_inputs"
nst_stylesubdir="${nst_workdir}/_styles"
nst_outsubdir="${nst_workdir}/_results"
mkdir "${nst_outsubdir}"
# TODO: how to iterate non-English names?
for i_content in $( ls "${nst_insubdir}" ); do
if [ -f "${nst_insubdir}/${i_content}" ]; then
for i_style in $( ls "${nst_stylesubdir}" ); do
if [ -f "${nst_stylesubdir}/${i_style}" ]; then
  echo '--------------------------------------------------------------------------------'
  echo "Model: '${nst_nick}'."
  echo ${nst_model}
  echo ${nst_proto}
  echo "Content layers: ${nst_cl}"
  echo "Content weight: ${nst_cw}"
  echo "Style layers: ${nst_sl}"
  echo "Style weight: ${nst_sw}"
  echo "Content image: '${nst_insubdir}/${i_content}'"
  echo "Style image: '${nst_stylesubdir}/${i_style}'"
  echo "Image size: ${nst_size} pixels."
  echo "${nst_iter} iterations."
  echo '---'
  echo "th neural_style.lua -proto_file "'"'"${nst_proto}"'"'" -model_file "'"'"${nst_model}"'"'" -content_layers "'"'"${nst_cl}"'"'" -style_layers "'"'"${nst_sl}"'"'" -output_image "'"'"${nst_outsubdir}/${nst_nick}-c${nst_cw}s${nst_sw}i${nst_iter}w${nst_size}x${nst_scale}_${i_content}_${i_style}.png"'"'" ${nst_ng} -content_weight ${nst_cw} -style_weight ${nst_sw} -style_image "'"'"${nst_stylesubdir}/${i_style}"'"'" -content_image "'"'"${nst_insubdir}/${i_content}"'"'" -gpu -1 -backend nn -seed ${nst_rnd} -optimizer ${nst_opti} -init image -image_size ${nst_size} -print_iter 1 -style_scale ${nst_scale} -num_iterations ${nst_iter} -save_iter ${nst_save}"
  echo '---'
        th neural_style.lua -proto_file "${nst_proto}"         -model_file "${nst_model}"         -content_layers "${nst_cl}"         -style_layers "${nst_sl}"         -output_image "${nst_outsubdir}/${nst_nick}-c${nst_cw}s${nst_sw}i${nst_iter}w${nst_size}x${nst_scale}_${i_content}_${i_style}.png"         ${nst_ng} -content_weight ${nst_cw} -style_weight ${nst_sw} -style_image "${nst_stylesubdir}/${i_style}"         -content_image "${nst_insubdir}/${i_content}"         -gpu -1 -backend nn -seed ${nst_rnd} -optimizer ${nst_opti} -init image -image_size ${nst_size} -print_iter 1 -style_scale ${nst_scale} -num_iterations ${nst_iter} -save_iter ${nst_save}
fi;done;fi;done