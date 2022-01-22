#!/bin/sh

# Display usage
cpack_usage()
{
  cat <<EOF
Usage: $0 [options]
Options: [defaults in brackets after descriptions]
  --help            print this message
  --version         print cmake installer version
  --prefix=dir      directory in which to install
  --include-subdir  include the unit_tests_module_usage_packager_api_expect_success_8-0.1.2-Linux subdirectory
  --exclude-subdir  exclude the unit_tests_module_usage_packager_api_expect_success_8-0.1.2-Linux subdirectory
  --skip-license    accept license
EOF
  exit 1
}

cpack_echo_exit()
{
  echo $1
  exit 1
}

# Display version
cpack_version()
{
  echo "unit_tests_module_usage_packager_api_expect_success_8 Installer Version: 0.1.2, Copyright (c) Humanity"
}

# Helper function to fix windows paths.
cpack_fix_slashes ()
{
  echo "$1" | sed 's/\\/\//g'
}

interactive=TRUE
cpack_skip_license=FALSE
cpack_include_subdir=""
for a in "$@"; do
  if echo $a | grep "^--prefix=" > /dev/null 2> /dev/null; then
    cpack_prefix_dir=`echo $a | sed "s/^--prefix=//"`
    cpack_prefix_dir=`cpack_fix_slashes "${cpack_prefix_dir}"`
  fi
  if echo $a | grep "^--help" > /dev/null 2> /dev/null; then
    cpack_usage
  fi
  if echo $a | grep "^--version" > /dev/null 2> /dev/null; then
    cpack_version
    exit 2
  fi
  if echo $a | grep "^--include-subdir" > /dev/null 2> /dev/null; then
    cpack_include_subdir=TRUE
  fi
  if echo $a | grep "^--exclude-subdir" > /dev/null 2> /dev/null; then
    cpack_include_subdir=FALSE
  fi
  if echo $a | grep "^--skip-license" > /dev/null 2> /dev/null; then
    cpack_skip_license=TRUE
  fi
done

if [ "x${cpack_include_subdir}x" != "xx" -o "x${cpack_skip_license}x" = "xTRUEx" ]
then
  interactive=FALSE
fi

cpack_version
echo "This is a self-extracting archive."
toplevel="`pwd`"
if [ "x${cpack_prefix_dir}x" != "xx" ]
then
  toplevel="${cpack_prefix_dir}"
fi

echo "The archive will be extracted to: ${toplevel}"

if [ "x${interactive}x" = "xTRUEx" ]
then
  echo ""
  echo "If you want to stop extracting, please press <ctrl-C>."

  if [ "x${cpack_skip_license}x" != "xTRUEx" ]
  then
    more << '____cpack__here_doc____'
LICENSE
=======

This is an installer created using CPack (https://cmake.org). No license provided.


____cpack__here_doc____
    echo
    while true
      do
        echo "Do you accept the license? [yn]: "
        read line leftover
        case ${line} in
          y* | Y*)
            cpack_license_accepted=TRUE
            break;;
          n* | N* | q* | Q* | e* | E*)
            echo "License not accepted. Exiting ..."
            exit 1;;
        esac
      done
  fi

  if [ "x${cpack_include_subdir}x" = "xx" ]
  then
    echo "By default the unit_tests_module_usage_packager_api_expect_success_8 will be installed in:"
    echo "  \"${toplevel}/unit_tests_module_usage_packager_api_expect_success_8-0.1.2-Linux\""
    echo "Do you want to include the subdirectory unit_tests_module_usage_packager_api_expect_success_8-0.1.2-Linux?"
    echo "Saying no will install in: \"${toplevel}\" [Yn]: "
    read line leftover
    cpack_include_subdir=TRUE
    case ${line} in
      n* | N*)
        cpack_include_subdir=FALSE
    esac
  fi
fi

if [ "x${cpack_include_subdir}x" = "xTRUEx" ]
then
  toplevel="${toplevel}/unit_tests_module_usage_packager_api_expect_success_8-0.1.2-Linux"
  mkdir -p "${toplevel}"
fi
echo
echo "Using target directory: ${toplevel}"
echo "Extracting, please wait..."
echo ""

# take the archive portion of this file and pipe it to tar
# the NUMERIC parameter in this command should be one more
# than the number of lines in this header file
# there are tails which don't understand the "-n" argument, e.g. on SunOS
# OTOH there are tails which complain when not using the "-n" argument (e.g. GNU)
# so at first try to tail some file to see if tail fails if used with "-n"
# if so, don't use "-n"
use_new_tail_syntax="-n"
tail $use_new_tail_syntax +1 "$0" > /dev/null 2> /dev/null || use_new_tail_syntax=""

extractor="pax -r"
command -v pax > /dev/null 2> /dev/null || extractor="tar xf -"

tail $use_new_tail_syntax +155 "$0" | gunzip | (cd "${toplevel}" && ${extractor}) || cpack_echo_exit "Problem unpacking the unit_tests_module_usage_packager_api_expect_success_8-0.1.2-Linux"

echo "Unpacking finished successfully"

exit 0
#-----------------------------------------------------------
#      Start of TAR.GZ file
#-----------------------------------------------------------;
� �B�a �=[p�uP��(ʖb=�hM�SP6!���G6A$�e �W�j�X[���B"��QF�G��V�O=�|8���m3�/U������h��t�f�Լd7I��6z�k�{��(���c�>���{ι���w]Ц	�"���ý"���ވ; F{���#=Ѯޘ�F{�{��^+��lٲ	�(�YX*���i9��ԿR��U��y�wŢ��_��Y�l�V-ے�F�\P��%ϪRIV�lJrI�Թ��ؒUVղ��ey��Woo��Q�k+��AC��f��o�!���[�]P���#=]��䞗^�w��kuYZ�s%Yϩ9q�4�b�d|�x|$!��S�~qz^Tp��MGo�P����:D����!O^�gUK���k����g�BA�VE�j�15�Vu��Ϋ������M4˺�ᗅxM/�m�E�Ļ�ݰ��K�~V��Y�����"*w�d�n���&Ӊ��	i(����OH�S�tb<+��2Y�p(��������T6���R��Y  �/)yUyV�N˦�v��"ą�E����Q�6�Ȋ� #�ŉb�fǳ�Q)�NO�z��x�)�4�b��"�%��j��> ��4y3�9jR7lQ��,[|KQ�(����).�d��-��\�h�(���(�a����8�P̂4��'�&'����RZX'Ձ�(���"Ip"/�t≩T:1Ē���YiZ�D��f,+��7�bj{K��@��+�rN�61��!�B���ǐ�'�~��f��Mpz�����j_`�V]\����C�TMK3��On3�w�G��'�k��kh`�����i���4�V2�B_�GfR㝠?�3c�?�n�/�lģl���몄�9�ʗ�`�v�HNu�A� W�8(���*hG�w��?�)yQ�u4��t��BD�C����k��@�2� �rD,���F�'�Ljb\J��fa$�W�&���c�65$B�!� ��n�#��Ta���@&7�P>Q��\��KFc^<�M�6~�X��0-�3h>9̸�Epqd&
�^`�B�ț<�҂�EN/�=�����n��X<�2����<tB�H�;:3�0��7��f�x:#���.����L���Q�=5>8:5����ܼ�,�h"�}Y36�ühi��w*w$��g�:��'��$|ٲ'�/["y�j�At�o�:S"�`��eeɦ���!�	�;��{��G+���9.��������3ode�a���x��*��o�(�j"������T�˨�i�#0��K�	��H:
�3Ԏ��'�
yt�P���/[�?`
�y�4�$xV�I=���.e"5$M��?"j�:�J4�(�柞��.�mG����!�S����ls�>#�ӫvw��Lkv�c�Hc`zJ�	�4i?
]��b��Xm���+aU�>�cQ��ĉ�tU�Ǝ�>�H��v��r��xG=��xf*��W]�i����Ytꆲ������t�z��_,�՘����K��:�ꪉ'Ud����!j�D4m6��k9 h�(aeAs�u��Y�8�<�e�:%B͉�����D:��h�iFq?�":R�W��=z����(k:ĪJ�F��vϬV�Q��ގԒ����۞e��Dve;Y�������'&��ER��SN�L�a�ψ��Ёu"6`�i�Z]��:�D�:G�щA��Ĕ��X��Ⱦ�¡iM_��.�d>z�4�Q�1�����q�TNf�k�c	��C3��DZZ]�kgS���P��y�<x��dh����F����5-xyM��s��p�����q��?����#���Ϛ�{���'x�gB?��Gl�vȩq�]�+��p/^��=���c� U,�^r{uN��%����̇&�2I���n� �G�t����#=��4�6�Y�*�b�`k�Z2)�2��]������\0U97OK�T!�o\�9th�*a�Gt�SkH��t5��!���N<Z��΢����p1�;�"�󌯜���KZp�����qM��d�� Z���q��K���1��k�Y�԰��V4�l'���Ɋv�q\�-~b�w?�V�m�D��~O�(�bh�l�Y,�;_�{�07�QSG[�gT���q䈠�I��}T�զ�ə^���U�AzW�W����^�괟)�mսwB�%�ρ�Q���9��;��N�q������g��^6#nV�˒j�K[��C�^Ϯݳ�5H.��uu{��]�U^��E.Ψ!�����χ`q����g�[ߝ�ߓ�8>���ʐ��p����v�A�d�u�3�H݂ȸ@����Y�:YT�U��%�VQ%�f�քEGL��P;%|�uDU�@����Di3����(+v�Γ���ԟ�>�Y�.�����OY]l8K�-�\>KȽ��}�v�����'��'۫7L�-b��dN���^�zW�{�$,���ei�7�\��[�����`�ݠ�ZPA�G !r?��Z��)�<�PC��zP��̓QRp.(������{N#�V�ʈ�H�j���x�[z�4��aj6��ډ-�^���^S��Öc4�!V�ni_�3B߮�9��E��r���r�~
LEb���%����`0��<���♳�ώ"P�a����-�h����k��P;CY��ٚ ���2Vt��p���Z�ʷ�/�����Fb��_�7��^��{��O4�x����������G>�N�IxL@���H���o>Z��/�	[���O
 �Ε��o��ّC��j"a����^�Dy���Xh��[�
������ay"�s�z�����m�:Ix��D�\k���|�h�KǼXz1+�:��G��W��w���������w��J�M�|I����L��o��|`՛����Å��j<TЦc=�
�΂���:��b����e��m��|jd|
U��ƪ��A�(~�w�O>���~����㵣�?.��G��hzV���Y��� �.����_U�]��Җ�zv@\��?�V'�+u��֡��u�#u��I�h��:r�v�&�o���T�h�g��)?��6&H�l��%4(ؒ$H�옔�u�,�?U3;6X0t5�F:��t��uP!�d�hT�˦d��f[)%;�M�����b*+e#R"�O�g�>Ͱ��Y�'C�P4qӍ���Ng����2
Vjy��,p�&�+~� �Y1�6��������4�f4].h�A%��
M�������Rw������]a<�k?n��0�&���Ϭ���kF��i������\ޣmB<�����������}�Y.p�S4}s����o>N0j{��!��\��]twu�E��_wћ]��.�&����^�2�F�����t�+���M.�7\t�8����^h@Ѐ4�e��m�����5'_\���`���������o5_��^��U~��mN�G����J�r	�8����e'܄����ms"�!� �Ʌ�r���p�ǩŷ>�\�~��nNfG/��h�������ʱ� ��w�r^\BGn�;�����o�\۶�*��!�y���u|�\�����Ǔ�o5%o$������2h�\��z��H�s��A��凧�珥È��;����^���V*�s`�7��%�<y=�o��H�c
�Ae�-.��\,���Z������'��נ�w"o$���_ ����]�8,�o�_x?P���­J�� F���_B�.�щ��0�Ӌ�������!�R��_���Dp�ˠ�3Wf���}��S?�F/��� ğL-�s|*���x6���T�b�: gF;>@>x�� _�����.-���{��?Z��xe�����G�����?�����3��ĥ+3U�H��_;�܀4�h@Ѐ4�oxN��5r����s]
>��y�Y����Z���mz�٢���Z�\ �Y��
��� � ��V*� 0:<�	X��J�������si!0�ػec� ���_Eڈ���_�%A�IDhmn���m��4��s�`��v��$�� ;[bt��@�wё�/��<�@�Dk�����A!�u���s��p����&��v�O���|�G�w���ֶ�	�Zw�vS�U��.���������}�7����}��H�54�*��hmhm��d=`�[��qNӀ4�h@Ѐ�r ���{h�{�n|?��������4�6峛�ٽ�������=8v���=����G/�9k���i{�Ƴ;h
Տݑ�E�N���%z���>OQ��{��_�西����H峻rL�'o�����(�C>G�Uh��u����������8��9����OR|��?����828xTMM�u�,	w�#���e�>�	Gz:y<��ʻ���A瞸����;���	��w��K���������b�����&�s������͎�z�[��C�*���V��K�&��9�5���N����{��I�߹���^���t�/�N��?���M�ZY��>$�Ы�����54�~��
OG�h�v��[+��۽�(�G?�e�&�Uy���Z;)��9>�8}�=_���+8�}B��{�����w��R�c�z7~Գ�'(n���������~u#��ֶ�Ø���c>;k����v�a>�~��K�[h��ҿDM��߾��T���/�yg��oh���y�ҿ^������n��e�������7��� ����<so����П}x��V����W�Ğ��F���'�^��	����u��-�)�>7�Ӡ����M$�U��u�{���m�瓪CW��Ӷ���LX��E$�()�]�%HRΐfƴ\�r�aZ�\�اr�H,����$�4�yI�ms^�1�5r�bq��B���r���^i��R	?��)i����,�q�l���$�O�4q�`OTB�;lM�|5��� ��Jr*ɇ�M$����(d)OK)�$D���񱄔B�i���))����PZ��>=KB�G����_�8&��3�����\՜l˂���d9M��G��*���)+�C��G.P[�!���͏�L�����dq�xM�c����!O��`&fIiڲ�o�A|n��G��q���EU�"ϭ})ę���U�WU�O���
ak�h�Ӏm��<�����$�u�Vóz9�>��"M��B�S�QR| �i˳���V^��uA�m��1	O@�8��%���*l�����*B<��ba��>V�u�sf5Dx��Ar�� J.j��d�J����/��V h���~�>��n�A���o��e�̅c\~���.=�NKq�ٺ�su������_���g��C�Ζ���@��,?[�0�G�t����&poD�{�����g��e�ٺ�a�?����d���l}�p�P�?(Ԗ��@l��u�l�ۏ���i~6�b�-�O�����+��-�P��_A���e.?[�1<ɥ矛����y��8>��\~�d��6�_���"�;��j��&���O�ʥ���7������p�y��'.��������ֵ'���G kD���'���y{5s�������3:����?��}4�} ��l#����')?�w�.J���!���8\�+���`�xc���Ϳ���7��W��8X���o?�sq"��o��{�����c�Kw7$|������u�_=J���߫���?��?����?ݱh�aA�Z�'fV��4�����U�Bs �  