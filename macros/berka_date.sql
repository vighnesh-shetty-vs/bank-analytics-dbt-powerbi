{#
  Berka stores dates as YYMMDD integers (e.g. 930705 = 1993-07-05). All dates in the
  dataset are 19xx, so the century is added explicitly instead of trusting a %y pivot.
#}
{% macro berka_date(column) -%}
    make_date(
        1900 + cast({{ column }} as integer) // 10000,
        (cast({{ column }} as integer) // 100) % 100,
        cast({{ column }} as integer) % 100
    )
{%- endmacro %}


{#
  Client birth numbers are YYMMDD for men and YY(MM+50)DD for women.
  Returns the month with the +50 offset removed.
#}
{% macro berka_birth_month(column) -%}
    ((cast({{ column }} as integer) // 100) % 100) % 50
{%- endmacro %}
