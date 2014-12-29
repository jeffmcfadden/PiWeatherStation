class OldStyleController < ApplicationController

  def c_to_f( f )
    (f * 1.8000 + 32.00 ).round(2)
  end

  def current_conditions
    output = `sudo rht03_and_exit`

    values = output.split( "," )

    temp_c = values[0].split( ":" )[1].strip.to_f
    rh   = values[1].split( ":" )[1].gsub( '%', '' ).strip.to_f

    tn = temp_c > 0 ? 243.12 : 272.62
     m = temp_c > 0 ? 17.62 : 22.46
    dew_point = tn * ( Math.log( rh / 100.0 ) + ( m * temp_c ) / ( tn + temp_c ) ) / ( m - Math.log( rh / 100.0 ) - ( m * temp_c ) / ( tn + temp_c ) )

    # [{"name":"Temperature","value":55.4},{"name":"Humidity","value":23.8},{"name":"Dewpoint","value":18.859867363465092}]

    render json: { temp_c: temp_c, temperature: c_to_f( temp_c.to_f ), humidity: rh, dewpoint: c_to_f(dew_point) }
  end

end
