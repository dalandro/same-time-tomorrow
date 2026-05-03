defmodule SameTimeTomorrowWeb.PageController do
  use SameTimeTomorrowWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
