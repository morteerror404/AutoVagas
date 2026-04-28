defmodule AutoVagasWeb.ErrorJSONTest do
  use AutoVagasWeb.ConnCase, async: true

  test "renders 404" do
    assert AutoVagasWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert AutoVagasWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
