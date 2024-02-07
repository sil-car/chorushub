#!/usr/bin/env bash

scripts_dir="$(dirname "$0")"
repo_dir="$(dirname "$scripts_dir")"
if [[ ! -d "${repo_dir}/.git" ]]; then
  echo "Error: Not repo base dir: $repo_dir"
  exit 1
fi
build_dir="${repo_dir}/build"
pkgs_dir="${build_dir}/pkgs"
stage_dir="${build_dir}/stage"
prime_dir="${build_dir}/prime"
mkdir -p "$pkgs_dir" "$stage_dir" "$prime_dir"

clean() {
  for d in pkgs stage prime; do
    if [[ $1 == "$d" ]]; then
      rm -rf "${build_dir:?}/${d}"
    fi
  done
  if [[ -z $1 || $1 == 'all' ]]; then
    rm -rf "${build_dir:?}"/*
  fi
}

# Grab fieldworks-applications focal package.
# NOTE: flexbridge also has these packages, but they're older versions.
debfile="fieldworks-applications_9.0.17.119+focal1_amd64.deb"
wget -P "$pkgs_dir" "http://packages.sil.org/ubuntu/pool/main/f/fieldworks/${debfile}"
dpkg-deb -x "${pkgs_dir}/${debfile}" "$stage_dir"
# Copy needed files to prime dir.
libs=(
  ChorusHub.exe
  LibChorus.dll
  SIL.Core.dll
)
for l in "${libs[@]}"; do
  cp -av "${stage_dir}/usr/lib/fieldworks/${l}" "${prime_dir}/usr/lib"
done

# Grab mono-6.12 focal packages.
pkgs=(
  ca-certificates-mono_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-2.0-1_6.12.0.200-0xamarin2+ubuntu2004b1_amd64.deb
  libmono-2.0-dev_6.12.0.200-0xamarin2+ubuntu2004b1_amd64.deb
  libmono-accessibility4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-btls-interface4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_amd64.deb
  libmono-cairo4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-cecil-private-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-cil-dev_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-codecontracts4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-compilerservices-symbolwriter4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-corlib4.5-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-cscompmgd0.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-csharp4.0c-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-custommarshalers4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-data-tds4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-db2-1.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-debugger-soft4.0a-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-http4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-i18n4.0-all_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-i18n4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-i18n-cjk4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-i18n-mideast4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-i18n-other4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-i18n-rare4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-i18n-west4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-ldap4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-management4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-messaging4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-messaging-rabbitmq4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-microsoft-build4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-microsoft-build-engine4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-microsoft-build-framework4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-microsoft-build-tasks-v4.0-4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-microsoft-build-utilities-v4.0-4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-microsoft-csharp4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-microsoft-visualc10.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-microsoft-web-infrastructure1.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-oracle4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-parallel4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-peapi4.0a-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-posix4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-rabbitmq4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-relaxng4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-security4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmonosgen-2.0-1_6.12.0.200-0xamarin2+ubuntu2004b1_amd64.deb
  libmonosgen-2.0-dev_6.12.0.200-0xamarin2+ubuntu2004b1_amd64.deb
  libmono-sharpzip4.84-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-simd4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-smdiagnostics0.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-sqlite4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-componentmodel-composition4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-componentmodel-dataannotations4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-configuration4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-configuration-install4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-core4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-data4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-data-datasetextensions4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-data-entity4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-data-linq4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-data-services4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-data-services-client4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-deployment4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-design4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-drawing4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-drawing-design4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-dynamic4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-enterpriseservices4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-identitymodel4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-identitymodel-selectors4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-io-compression4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-io-compression-filesystem4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-json4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-json-microsoft4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-ldap4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-ldap-protocols4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-management4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-messaging4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-net4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-net-http4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-net-http-formatting4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-net-http-webrequest4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-numerics4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-numerics-vectors4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-reactive-core2.2-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-reactive-debugger2.2-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-reactive-experimental2.2-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-reactive-interfaces2.2-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-reactive-linq2.2-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-reactive-observable-aliases0.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-reactive-platformservices2.2-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-reactive-providers2.2-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-reactive-runtime-remoting2.2-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-reactive-windows-forms2.2-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-reactive-windows-threading2.2-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-reflection-context4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-runtime4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-runtime-caching4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-runtime-durableinstancing4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-runtime-serialization4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-runtime-serialization-formatters-soap4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-security4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-servicemodel4.0a-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-servicemodel-activation4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-servicemodel-discovery4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-servicemodel-internals0.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-servicemodel-routing4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-servicemodel-web4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-serviceprocess4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-threading-tasks-dataflow4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-transactions4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-web4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-web-abstractions4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-web-applicationservices4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-web-dynamicdata4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-web-extensions4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-web-extensions-design4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-web-http4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-web-http-selfhost4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-web-http-webhost4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-web-mobile4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-web-mvc3.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-web-razor2.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-web-regularexpressions4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-web-routing4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-web-services4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-web-webpages2.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-web-webpages-deployment2.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-web-webpages-razor2.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-windows4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-windows-forms4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-windows-forms-datavisualization4.0a-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-workflow-activities4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-workflow-componentmodel4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-workflow-runtime4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-xaml4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-xml4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-xml-linq4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-system-xml-serialization4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-tasklets4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-webbrowser4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-webmatrix-data4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-windowsbase4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  libmono-xbuild-tasks4.0-cil_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  mono-4.0-gac_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  mono-csharp-shell_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  mono-devel_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  mono-gac_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  mono-llvm-support_6.12.0.200-0xamarin2+ubuntu2004b1_amd64.deb
  mono-mcs_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  mono-roslyn_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
  mono-runtime_6.12.0.200-0xamarin2+ubuntu2004b1_amd64.deb
  mono-runtime-common_6.12.0.200-0xamarin2+ubuntu2004b1_amd64.deb
  mono-runtime-sgen_6.12.0.200-0xamarin2+ubuntu2004b1_amd64.deb
  mono-xbuild_6.12.0.200-0xamarin2+ubuntu2004b1_all.deb
)
for p in "${pkgs[@]}"; do
  wget -P "$pkgs_dir" "https://download.mono-project.com/repo/ubuntu/pool/main/m/mono/${p}"
  dpkg-deb -x "${pkgs_dir}/${p}" "$stage_dir"
done
# Fix wrong symlink.
mkdir -p "${stage_dir}/usr/share"
rm -f "${stage_dir}/usr/share/.mono"
ln -r -s "${stage_dir}/etc/mono/certstore" "${stage_dir}/usr/share/.mono"
# Copy needed files to prime dir.
cp -av "${stage_dir}"/* "${prime_dir}"
