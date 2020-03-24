#!/bin/bash

recipe="/vagrant/recipes/graylog-sidecar-repository/recipe.rb"
systems=${1:-ubuntu1404 centos7}
pkg_dir="/home/bernd/test/vm-oses/packages"

for os in $systems; do
	vagrant docker-run $os -- fpm-cook clean $recipe
	vagrant docker-run $os -- fpm-cook package -q $recipe || exit 1
done

for pkg in pkg/*.{deb,rpm}; do
	case "$pkg" in
	*.deb)
		target="deb"
		;;
	*.rpm)
		target="rpm"
		;;
	esac

	echo "====> Copy $pkg to $pkg_dir/$target"
	mkdir -p $pkg_dir/$target
	cp -p $pkg $pkg_dir/$target/
done
