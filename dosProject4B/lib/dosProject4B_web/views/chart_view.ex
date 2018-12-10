defmodule DosProject4BWeb.ChartView do
  use DosProject4BWeb, :view

  use Task

  def start_link(_arg) do
    Task.start_link(&my_name/0)
  end

  # def poll() do
  #   receive do
  #   after
  #     1000 ->
  #       get_price()
  #       #poll()
  #   end
  # end

  # defp get_price() do
  #   value = :rand.uniform(10) * 10
  #   IO.puts value
  #   value
  # end


  def my_name() do
    :rand.uniform(10) * 10
    IO.puts "mint"
  end
end

