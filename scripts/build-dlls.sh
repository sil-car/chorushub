#!/usr/bin/env bash

repo_dir="$(dirname "$(dirname "$0")")"
out_dir="${repo_dir}/dist"
src_dir="${repo_dir}/src"

build_dll() {
    filename="$1"
    aname="$2[@]"
    src_paths=("${!aname}")
    ref_paths=()
    if [[ -n $3 ]]; then
        rname="$3[@]"
        ref_paths=("${!rname}")
    fi
    ref_list=''
    for p in "${ref_paths[@]}"; do
        ref_list+="${p},"
    done
    ref_list="${ref_list%,*}" # remove final comma

    optargs=(
        -target:library
        -out:"${out_dir}/${filename}"
    )
    if [[ ${#ref_paths} -gt 0 ]]; then
        optargs+=("-reference:${ref_list}")
    fi
    echo "Building ${out_dir}/${filename}"
    csc "${optargs[@]}" \
        -reference:"${out_dir}/Chorus.ChorusHub.dll" \
        "${src_paths[@]}"
}

# Chorus.ChorusHub.dll
build_files=(
    "${src_dir}/LibChorus/ChorusHub/IChorusHubService.cs"
)
ref_files=()
build_dll "Chorus.ChorusHub.dll" build_files

# Chorus.Utilities.dll
build_files=(
    "${src_dir}/libchorus/utilities/UrlHelper.cs"
)
ref_files=()
build_dll "Chorus.Utilities.dll" build_files

# Chorus.VcsDrivers.dll
build_files=(
    "${src_dir}/libchorus/vcsdrivers/RepositoryInformation.cs"
)
ref_files=()
build_dll "Chorus.VcsDrivers.dll" build_files


# ChorusHub.dll
build_files=(
    "${src_dir}/chorushub/ChorusHubService.cs"
)
ref_files=(
    "${out_dir}/Chorus.ChorusHub.dll"
    "${out_dir}/Chorus.Utilities.dll"
    "${out_dir}/Chorus.VcsDrivers.dll"
)
build_dll "ChorusHub.dll" build_files ref_files
