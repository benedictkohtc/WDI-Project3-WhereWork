class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :registerable,
         :timeoutable,
         :validatable,
         timeout_in: 2.hours,
         password_length: 1..128
end
