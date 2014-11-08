class RulesController < ApplicationController

	before_filter :set_rule, only: [:edit, :update]
	before_filter :set_rules, only: [:index]

  # GET /rules
  def index
  	if @grade
  		render 'grade_form' #maybe just put this on the index template in an if statement
  	end
  end

  # GET /rules/1/edit
  def edit
  end

  # PATCH/PUT /rules/1
  def update
    if @rule.update(rule_params)
      redirect_to rules_path, notice: 'Rule was successfully updated.'
    else
      render :edit
    end
  end

	private

    # Use callbacks to share common setup or constraints between actions.
    def set_rule
      @rule = Rule.find(params[:id])
      authorize @rule
    end

		def set_rules
			if !params[:grade_id]
				@rules = policy_scope(Rule).template.ordered
			else
				@grade = Grade.find(params[:grade_id])
				@rules = policy_scope(@grade.rules)
			end
			authorize @rules
		end

		# Only allow a trusted parameter "white list" through.
    def rule_params
      params.require(:rule).permit(:name)
      #:grade_to_copy, :position_id, *Location::DAY_PARAMS, speeds_attributes: [:id, :doctors, :normal, :max] )
    end
end
