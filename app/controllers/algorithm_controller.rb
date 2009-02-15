# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'algorithm'

class AlgorithmController < ApplicationController

  def index

    Algorithm.schedule_output_generation

    render :text => "verificare sull'output la stampa del numero"
  end
end
