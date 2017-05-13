#!/bin/bash

# Instructions:
# - Download "Vägdata > Kommuner/Län Shape" shape packages from
#   Lastkajen (https://lastkajen.trafikverket.se/107_OA_FileStorage/Default.aspx)
# - Extract them in subdirectories relative to this script
# - Run the script and it will generate a Mapserver map file
#
# Requires ogrinfo.


out=/dev/stdout

cat > "${out}" <<EOF
MAP
  NAME "NVDB names"
  IMAGETYPE   PNG
  EXTENT      269646.879000 6133589.947000 917085.660000 7654982.170000
  SHAPEPATH   "."

  PROJECTION
    "init=epsg:3857"
  END

  CONFIG "MS_ERRORFILE" "mapserver_names.err"
  DEBUG 2

  WEB
    METADATA
      "wms_title" "NVDB"
      "wms_onlineresource" "http://mapproxy.openstreetmap.se/service?"
      "wms_enable_request" "*"
    END
  END

  SYMBOL
    NAME "circle"
    TYPE ellipse # Type of symbol
    POINTS
      1 1
    END
    FILLED true
    ANCHORPOINT 0.5 0.5
  END
EOF

names=""

for shp in */*NVDB*namn.shp; do
  name=$(ogrinfo -ro -al -so "${shp}" | grep "Layer name:" | sed -e 's/Layer name: //')
  extent=$(ogrinfo -ro -al -so "${shp}" | grep "Extent:" | sed -e 's/Extent: //' -e 's/[\(\),-]//g')
  cat > "${out}" <<EOF
  LAYER
    NAME      "${name}"
    DATA      "${shp}"
    STATUS    DEFAULT
    TYPE      LINE
    EXTENT    ${extent}
    PROJECTION
      AUTO
    END
    #SYMBOLSCALEDENOM 5000
    LABELITEM "NAMN"
    CLASS
      STYLE
        COLOR 0 0 0
        WIDTH 2
        MINWIDTH 1
        MAXWIDTH 8
        MAXSCALEDENOM 240000
        MINSCALEDENOM 15000
      END
      #STYLE
      #  GEOMTRANSFORM "start"
      #  COLOR 255 0 0
      #  SYMBOL "circle"
      #  SIZE 3
      #  MAXSCALEDENOM 15000
      #END
      #STYLE
      #  GEOMTRANSFORM "end"
      #  COLOR 255 0 0
      #  SYMBOL "circle"
      #  SIZE 3
      #  MAXSCALEDENOM 15000
      #END
      LABEL
        COLOR 255 255 255
        OUTLINECOLOR 48 48 48
        MAXSCALEDENOM 15000
        ANGLE FOLLOW
        SIZE medium
      END
    END
  END
EOF
  names="${name},${names}"
done

cat >> "$out" <<EOF
  LAYER
    NAME "names"
    TYPE LINE
    STATUS ON
    CONNECTIONTYPE UNION
    CONNECTION "${names%,}"
    CLASS
    END
  END
EOF

cat >> "${out}" <<EOF
END
EOF
