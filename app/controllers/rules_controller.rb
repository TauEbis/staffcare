class RulesController < ApplicationController

  before_filter :set_rule,  only: [:edit, :update]
	before_filter :set_rules, only: [:index]


  # GET /rules
  def index
    @title = (@grade ? "Edit Default Rules" : "All Rules")
  end

  # GET /rules/1/edit
  def edit
    @back_path = rules_back_path
  end

  # PATCH/PUT /rules/1
  def update
    if @rule.update(rule_params)
      redirect_to rules_back_path, notice: 'Rule was successfully updated.'
    else
      render :edit
    end
  end

	private

    # Use callbacks to share common setup or constraints between actions.
    def set_rule
      @rule = Rule.find(params[:id])
      authorize @rule
      @grade=@rule.grade
    end

		def set_rules
			if params[:id] # this will be a grade id
				@grade = Grade.find(params[:id])
        @rules = @grade.rules
			else
        @rules = Rule.template.ordered
			end
      policy_scope @rules
			authorize @rules
		end

		# Only allow a trusted parameter "white list" through.
    def rule_params
      params.require(:rule).permit(:name)
    end

    def rules_back_path
      @grade ? rules_grade_path(@grade) : rules_path
    end
end
